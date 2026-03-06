import credits.aleo;
program credit_transfer.aleo;

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

constructor:
    assert.eq program_owner aleo1n4ws5s7vlt4cff9rk5vwuwza4vjja03my4p9j8d45fxy0ady6uzq9jjujy;
