program token.aleo {
    mapping minted_once: address => bool;
    mapping balances: address => u64;

    record Token {
        owner: address,
        amount: u64,
    }

    // One address can mint tokens only once
    async transition mint(owner: address, amount: u64) -> (Token, Future) {
        assert_eq(owner, self.caller);
        let token_record: Token = Token {
            owner: owner,
            amount: amount,
        };
        return (token_record, check(owner, amount));
    }

    // this check if the caller has already minted or not, and updates the balance of the caller
    async function check(owner: address, amount: u64) {
        let already_minted: bool = Mapping::get_or_use(minted_once, owner, false);
        assert_eq(already_minted, false);
        Mapping::set(minted_once, owner, true);
        let current_balance: u64 = Mapping::get_or_use(balances, owner, 0u64);
        let new_balance: u64 = current_balance + amount;
        Mapping::set(balances, owner, new_balance);
    }

    // token transfer from one address to another, the caller must be the owner of the token
    async transition transfer(token: Token, to: address, amount: u64) -> (Token, Token, Future) {
        assert_eq(token.owner, self.caller);
        assert(token.amount >= amount);
        let Remaining: u64 = token.amount - amount;
        let remaining: Token = Token {
            owner: token.owner,
            amount: Remaining,
        };
        let transferred: Token = Token {
            owner: to,
            amount: amount,
        };
        return (remaining, transferred, update_balances(token.owner, to, amount));
    }

    // this function updates the balances of the sender and the receiver after a transfer
    async function update_balances(from: address, to: address, amount: u64) {
        let from_balance: u64 = Mapping::get_or_use(balances, from, 0u64);
        let updated_from_balance: u64 = from_balance - amount;
        Mapping::set(balances, from, updated_from_balance);
        let to_balance: u64 = Mapping::get_or_use(balances, to, 0u64);
        let updated_to_balance: u64 = to_balance + amount;
        Mapping::set(balances, to, updated_to_balance);
    }

    @noupgrade
    async constructor() {}
}
