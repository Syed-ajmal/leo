import credits.aleo;

program dao.aleo {

    const ADMIN: address = aleo1nz5cpl2mmu3hmzmxamp2g2fk2zu46ha53r566nc5tjzgwl4qmc8se2z4yv;
    const TREASURY_WALLET: address = aleo1ekza6x7zftmgx9snh5j3h7ds0tw8qmzugh7sr0sfu72cvfe87yzsuxsewm;

    const MEMBER_1: address = aleo13hfyln9uyq7epkqg4hcmlrfml4v0nl4ze7zqstd6wy25tqej3syqcs699l;
    const MEMBER_2: address = aleo1xgg3n4qd5tczru5xdarytkdsww7hzd0fpzq2vl33z0cdatghvyqqcgm5yg;
    const MEMBER_3: address = aleo1ulp725qyzksnnwe8cpzy36uj0q39ev9fta7w52u45g0sa8qa258snwn7u2;

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

    mapping proposals: field => Proposal;  // proposal_id → Proposal
    mapping has_voted: field => bool;       // hash(member + proposal_id) → voted? to prevent double voting

    inline is_member(addr: address) -> bool {
        return  addr == MEMBER_1 ||
                addr == MEMBER_2 ||
                addr == MEMBER_3;
    }

    // Create a proposal to withdraw from treasury--admin only
    async transition create_proposal(
        proposal_id: field,
        recipient: address,
        amount: u64
    ) -> Future {
        assert_eq(self.caller, ADMIN);
        assert(amount > 0u64);
        let proposal: Proposal = Proposal {
            recipient: recipient,
            amount: amount,
            vote_count: 0u8,
            reject_count: 0u8,
            is_approved: false,
            is_executed: false,
            is_active: true,
        };

        return create_proposal_internal(proposal_id, proposal);
    }

    async function create_proposal_internal(proposal_id: field, proposal: Proposal) {
    let exists: bool = Mapping::contains(proposals, proposal_id);
    assert(!exists);  // proposal_id must be unique
    Mapping::set(proposals, proposal_id, proposal);
    }

    // Vote on a proposal--members only
    async transition vote(
        proposal_id: field,
        approve:     bool
    ) -> Future {
        assert(is_member(self.caller));

        // Hash member address + proposal_id → unique vote key
        // Prevents same member voting twice on same proposal
        let vote_key: field = BHP256::hash_to_field(self.caller) + proposal_id;

        return vote_internal(proposal_id, vote_key, approve);
    }

    async function vote_internal(
        proposal_id: field,
        vote_key: field,
        approve: bool
    ) {
        // Block double voting
        let already_voted: bool = Mapping::get_or_use(has_voted, vote_key, false);
        assert(!already_voted);
        Mapping::set(has_voted, vote_key, true);

        // Get proposal
        let p: Proposal = Mapping::get(proposals, proposal_id);

        // Must be active and not executed
        assert(p.is_active);
        assert(!p.is_executed);

        // Update vote counts
        let new_vote_count:   u8 = approve ? p.vote_count + 1u8 : p.vote_count;
        let new_reject_count: u8 = approve ? p.reject_count : p.reject_count + 1u8;

        // Check if majority reached
        let now_approved: bool = new_vote_count >= MAJORITY;

        // Check if majority rejected → cancel
        let now_cancelled: bool = new_reject_count >= MAJORITY;

        let updated: Proposal = Proposal {
            recipient:    p.recipient,
            amount:       p.amount,
            vote_count:   new_vote_count,
            reject_count: new_reject_count,
            is_approved:  now_approved,
            is_executed:  false,
            is_active:    !now_cancelled, //  cancelled if majority rejected
        };

        Mapping::set(proposals, proposal_id, updated);
    }

    // Execute an approved proposal--treasury wallet only
    async transition execute_withdrawal(
        proposal_id: field,
        recipient: address,
        amount: u64
    ) -> Future {
        assert_eq(self.caller, TREASURY_WALLET);

        // self.caller = TREASURY_WALLET → credits deducted from treasury
        let f: Future = credits.aleo/transfer_public(recipient, amount);

        return execute_withdrawal_internal(proposal_id, recipient, amount, f);
    }

    async function execute_withdrawal_internal(
        proposal_id: field,
        recipient: address,
        amount: u64,
        f: Future
    ) {
        let p: Proposal = Mapping::get(proposals, proposal_id);

        // Must be approved by majority
        assert(p.is_approved);
        assert(!p.is_executed);
        assert(p.is_active);

        // Verify recipient and amount match proposal
        assert_eq(p.recipient, recipient);
        assert_eq(p.amount, amount);

        // Await the transfer future
        f.await();

        // Mark executed
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

    // Cancel a proposal--admin only
    async transition cancel_proposal(proposal_id: field) -> Future {
        assert_eq(self.caller, ADMIN);
        return cancel_internal(proposal_id);
    }

    async function cancel_internal(proposal_id: field) {
        let p: Proposal = Mapping::get(proposals, proposal_id);

        assert(!p.is_executed);
        assert(p.is_active);

        let cancelled: Proposal = Proposal {
            recipient:    p.recipient,
            amount:       p.amount,
            vote_count:   p.vote_count,
            reject_count: p.reject_count,
            is_approved:  p.is_approved,
            is_executed:  false,
            is_active:    false, // ← cancelled
        };

        Mapping::set(proposals, proposal_id, cancelled);
    }
}