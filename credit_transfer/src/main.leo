import credits.aleo;

program credit_transfer.aleo {

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

    @admin(address = "aleo1n4ws5s7vlt4cff9rk5vwuwza4vjja03my4p9j8d45fxy0ady6uzq9jjujy")
    async constructor() {}
}