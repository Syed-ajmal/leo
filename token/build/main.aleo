program token.aleo;

record Token:
    owner as address.private;
    amount as u64.private;

mapping minted_once:
    key as address.public;
    value as boolean.public;

mapping balances:
    key as address.public;
    value as u64.public;

function mint:
    input r0 as u64.private;
    assert.eq aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px self.caller;
    cast aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px r0 into r1 as Token.record;
    async mint aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px r0 into r2;
    output r1 as Token.record;
    output r2 as token.aleo/mint.future;

finalize mint:
    input r0 as address.public;
    input r1 as u64.public;
    get.or_use minted_once[r0] false into r2;
    assert.eq r2 false;
    set true into minted_once[r0];
    get.or_use balances[r0] 0u64 into r3;
    add r3 r1 into r4;
    set r4 into balances[r0];

function transfer:
    input r0 as Token.record;
    input r1 as address.private;
    input r2 as u64.private;
    assert.eq r0.owner self.caller;
    gte r0.amount r2 into r3;
    assert.eq r3 true;
    sub r0.amount r2 into r4;
    cast r0.owner r4 into r5 as Token.record;
    cast r1 r2 into r6 as Token.record;
    async transfer r0.owner r1 r2 into r7;
    output r5 as Token.record;
    output r6 as Token.record;
    output r7 as token.aleo/transfer.future;

finalize transfer:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u64.public;
    get.or_use balances[r0] 0u64 into r3;
    gte r3 r2 into r4;
    assert.eq r4 true;
    sub r3 r2 into r5;
    set r5 into balances[r0];
    get.or_use balances[r1] 0u64 into r6;
    add r6 r2 into r7;
    set r7 into balances[r1];

function get_address:
    output self.caller as address.private;

constructor:
    assert.eq edition 0u16;
