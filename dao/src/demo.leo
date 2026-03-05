import credits.aleo;

program dao.aleo {

    const ADMIN: address           = aleo1nz5cpl2mmu3hmzmxamp2g2fk2zu46ha53r566nc5tjzgwl4qmc8se2z4yv;
    const TREASURY_WALLET: address = aleo1ekza6x7zftmgx9snh5j3h7ds0tw8qmzugh7sr0sfu72cvfe87yzsuxsewm;

    const MEMBER_1: address = aleo13hfyln9uyq7epkqg4hcmlrfml4v0nl4ze7zqstd6wy25tqej3syqcs699l;
    const MEMBER_2: address = aleo1xgg3n4qd5tczru5xdarytkdsww7hzd0fpzq2vl33z0cdatghvyqqcgm5yg;
    const MEMBER_3: address = aleo1ulp725qyzksnnwe8cpzy36uj0q39ev9fta7w52u45g0sa8qa258snwn7u2;

    // A proposal passes or is rejected when it reaches this many votes
    const MAJORITY: u8 = 2u8;

    struct Proposal {
        recipient:    address,
        amount:       u64,
        vote_count:   u8,
        reject_count: u8,
        is_approved:  bool,
        is_executed:  bool,
        is_active:    bool,
    }

    // proposal_id (field) → Proposal
    mapping proposals: field => Proposal;

    // Prevents double-voting per member per proposal
    mapping has_voted: field => bool;

    // Monotonically increasing proposal counter to prevent front-running on proposal_id
    mapping proposal_counter: bool => field;

    inline is_member(addr: address) -> bool {
        return addr == MEMBER_1 ||
               addr == MEMBER_2 ||
               addr == MEMBER_3;
    }

    // Returns the newly assigned proposal_id so the caller can record it off-chain.
    async transition create_proposal(
        recipient: address,
        amount:    u64
    ) -> Future {
        assert_eq(self.caller, ADMIN);
        assert(amount > 0u64);

        let proposal: Proposal = Proposal {
            recipient:    recipient,
            amount:       amount,
            vote_count:   0u8,
            reject_count: 0u8,
            is_approved:  false,
            is_executed:  false,
            is_active:    true,
        };

        return create_proposal_internal(proposal);
    }

    async function create_proposal_internal(proposal: Proposal) {
        // Use an on-chain counter as the proposal_id — prevents front-running
        let counter: field = Mapping::get_or_use(proposal_counter, true, 0field);
        let new_id: field  = counter + 1field;

        Mapping::set(proposal_counter, true, new_id);
        Mapping::set(proposals, new_id, proposal);
    }

    async transition vote(
        proposal_id: field,
        approve:     bool
    ) -> Future {
        assert(is_member(self.caller));
        return vote_internal(proposal_id, self.caller, approve);
    }

    async function vote_internal(
        proposal_id: field,
        member:      address,
        approve:     bool
    ) {
        let vote_key: field = BHP256::hash_to_field((member, proposal_id));
        let already_voted: bool = Mapping::get_or_use(has_voted, vote_key, false);
        assert(!already_voted);
        Mapping::set(has_voted, vote_key, true);

        // ── Fetch proposal ─────────────────────────────────────────────
        let p: Proposal = Mapping::get(proposals, proposal_id);
        assert(p.is_active);
        assert(!p.is_executed);

        // ── Tally ──────────────────────────────────────────────────────
        let new_vote_count:   u8 = approve ? p.vote_count   + 1u8 : p.vote_count;
        let new_reject_count: u8 = approve ? p.reject_count       : p.reject_count + 1u8;

        let now_approved:  bool = new_vote_count   >= MAJORITY;
        let now_cancelled: bool = new_reject_count >= MAJORITY;

        let still_active:  bool = !now_cancelled;
        let final_approved: bool = now_approved && still_active;

        let updated: Proposal = Proposal {
            recipient:    p.recipient,
            amount:       p.amount,
            vote_count:   new_vote_count,
            reject_count: new_reject_count,
            is_approved:  final_approved,
            is_executed:  false,
            is_active:    still_active,
        };

        Mapping::set(proposals, proposal_id, updated);
    }

    async transition execute_withdrawal(
        proposal_id: field,
        recipient:   address,
        amount:      u64
    ) -> Future {
        assert_eq(self.caller, TREASURY_WALLET);

        let f: Future = credits.aleo/transfer_public(recipient, amount);

        return execute_withdrawal_internal(proposal_id, recipient, amount, f);
    }

    async function execute_withdrawal_internal(
        proposal_id: field,
        recipient:   address,
        amount:      u64,
        f:           Future
    ) {
        let p: Proposal = Mapping::get(proposals, proposal_id);

        // Proposal must be approved, active, and not already executed
        assert(p.is_approved);
        assert(p.is_active);
        assert(!p.is_executed);

        // The on-chain values must match what was passed to the transition
        assert_eq(p.recipient, recipient);
        assert_eq(p.amount,    amount);

        // Settle the transfer — if this fails the entire transaction reverts
        f.await();

        let executed: Proposal = Proposal {
            recipient:    p.recipient,
            amount:       p.amount,
            vote_count:   p.vote_count,
            reject_count: p.reject_count,
            is_approved:  p.is_approved,
            is_executed:  true,
            is_active:    false,
        };

        Mapping::set(proposals, proposal_id, executed);
    }


    async transition cancel_proposal(proposal_id: field) -> Future {
        assert_eq(self.caller, ADMIN);
        return cancel_internal(proposal_id);
    }

    async function cancel_internal(proposal_id: field) {
        let p: Proposal = Mapping::get(proposals, proposal_id);

        assert(p.is_active);
        assert(!p.is_executed);

        let cancelled: Proposal = Proposal {
            recipient:    p.recipient,
            amount:       p.amount,
            vote_count:   p.vote_count,
            reject_count: p.reject_count,
            is_approved:  false,  // clear approval on cancellation
            is_executed:  false,
            is_active:    false,
        };

        Mapping::set(proposals, proposal_id, cancelled);
    }
}
