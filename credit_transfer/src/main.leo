import credits.aleo;

program credit_transfer.aleo {

    // mapping to track who deposited how much
    mapping deposits: address => u64;

    // ── Deposit: user sends credits TO the program ───────────────
    async transition deposit(
        public amount: u64
    ) -> Future {
        // transfer FROM signer TO vault program address
        let f: Future = credits.aleo/transfer_public_as_signer(self.address, amount);
        return finalize_deposit(f, self.signer, amount);
    }

    async function finalize_deposit(f: Future, depositor: address, amount: u64) {
        f.await();
        // track deposit
        let current: u64 = Mapping::get_or_use(deposits, depositor, 0u64);
        Mapping::set(deposits, depositor, current + amount);
    }

    async transition withdraw(
        public recipient: address,
        public amount:    u64
    ) -> Future {
        // transfer FROM program balance TO recipient
        let f: Future = credits.aleo/transfer_public(recipient, amount);
        return finalize_withdraw(f, recipient, amount);
    }

    async function finalize_withdraw(f: Future, recipient: address, amount: u64) {
        // check recipient has enough deposited
        let balance: u64 = Mapping::get(deposits, recipient);
        assert(balance >= amount);
        Mapping::set(deposits, recipient, balance - amount);
        f.await();
    }

    async transition check_balance() -> Future {
        return finalize_check();
    }

    async function finalize_check() {
        let balance: u64 = Mapping::get_or_use(
            credits.aleo/account, 
            self.address, 
            0u64
        );
        assert(balance > 0u64);
    }

    async transition transfer(
        recipient: address,
        amount:    u64
    ) -> Future {
        let f: Future = credits.aleo/transfer_public(recipient, amount);
        return finalize_transfer(f);
    }

    async function finalize_transfer(f: Future) {
        f.await();
    }

    async transition transfer2(
        public recipient: address,
        public amount:    u64
    ) -> Future {
        let f: Future = credits.aleo/transfer_public(recipient, amount);
        return finalize_transfer2(f);
    }

    async function finalize_transfer2(f: Future) {
        f.await();
    }

    async transition transfer3(
        public recipient: address,
        public amount:    u64
    ) -> Future {
        let f: Future = credits.aleo/transfer_public_as_signer(recipient, amount);
        return finalize_transfer3(f);
    }

    async function finalize_transfer3(f: Future) {
        f.await();
    }

    @admin(address = "aleo1n4ws5s7vlt4cff9rk5vwuwza4vjja03my4p9j8d45fxy0ady6uzq9jjujy")
    async constructor() {}
}