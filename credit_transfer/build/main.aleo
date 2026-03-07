import credits.aleo;
program credit_transfer.aleo;

mapping deposits:
    key as address.public;
    value as u64.public;

function deposit:
    input r0 as u64.public;
    call credits.aleo/transfer_public_as_signer credit_transfer.aleo r0 into r1;
    async deposit r1 self.signer r0 into r2;
    output r2 as credit_transfer.aleo/deposit.future;

finalize deposit:
    input r0 as credits.aleo/transfer_public_as_signer.future;
    input r1 as address.public;
    input r2 as u64.public;
    await r0;
    get.or_use deposits[r1] 0u64 into r3;
    add r3 r2 into r4;
    set r4 into deposits[r1];

function withdraw:
    input r0 as address.public;
    input r1 as u64.public;
    call credits.aleo/transfer_public r0 r1 into r2;
    async withdraw r2 r0 r1 into r3;
    output r3 as credit_transfer.aleo/withdraw.future;

finalize withdraw:
    input r0 as credits.aleo/transfer_public.future;
    input r1 as address.public;
    input r2 as u64.public;
    get deposits[r1] into r3;
    gte r3 r2 into r4;
    assert.eq r4 true;
    sub r3 r2 into r5;
    set r5 into deposits[r1];
    await r0;

function check_balance:
    async check_balance into r0;
    output r0 as credit_transfer.aleo/check_balance.future;

finalize check_balance:
    get.or_use credits.aleo/account[credit_transfer.aleo] 0u64 into r0;
    gt r0 0u64 into r1;
    assert.eq r1 true;

function transfer:
    input r0 as address.private;
    input r1 as u64.private;
    call credits.aleo/transfer_public r0 r1 into r2;
    async transfer r2 into r3;
    output r3 as credit_transfer.aleo/transfer.future;

finalize transfer:
    input r0 as credits.aleo/transfer_public.future;
    await r0;

function transfer2:
    input r0 as address.public;
    input r1 as u64.public;
    call credits.aleo/transfer_public r0 r1 into r2;
    async transfer2 r2 into r3;
    output r3 as credit_transfer.aleo/transfer2.future;

finalize transfer2:
    input r0 as credits.aleo/transfer_public.future;
    await r0;

function transfer3:
    input r0 as address.public;
    input r1 as u64.public;
    call credits.aleo/transfer_public_as_signer r0 r1 into r2;
    async transfer3 r2 into r3;
    output r3 as credit_transfer.aleo/transfer3.future;

finalize transfer3:
    input r0 as credits.aleo/transfer_public_as_signer.future;
    await r0;

constructor:
    assert.eq program_owner aleo1n4ws5s7vlt4cff9rk5vwuwza4vjja03my4p9j8d45fxy0ady6uzq9jjujy;
