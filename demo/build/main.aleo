program demo.aleo;

mapping principal:
    key as address.public;
    value as u64.public;

mapping rewards:
    key as address.public;
    value as u64.public;

mapping last_update_block:
    key as address.public;
    value as u32.public;

function calculate_reward:
    input r0 as u64.private;
    input r1 as u32.private;
    cast r1 into r2 as u64;
    mul r0 1200u64 into r3;
    mul r3 r2 into r4;
    div r4 315360000000u64 into r5;
    output r5 as u64.private;

function stake:
    input r0 as u64.private;
    input r1 as u32.private;
    gt r0 0u64 into r2;
    assert.eq r2 true;
    async stake self.caller r0 r1 into r3;
    output r3 as demo.aleo/stake.future;

finalize stake:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as u32.public;
    get.or_use principal[r0] 0u64 into r3;
    get.or_use rewards[r0] 0u64 into r4;
    get.or_use last_update_block[r0] r2 into r5;
    gte r2 r5 into r6;
    assert.eq r6 true;
    sub r2 r5 into r7;
    cast r7 into r8 as u64;
    mul r3 1200u64 into r9;
    mul r9 r8 into r10;
    div r10 315360000000u64 into r11;
    add r3 r1 into r12;
    set r12 into principal[r0];
    add r4 r11 into r13;
    set r13 into rewards[r0];
    set r2 into last_update_block[r0];

function claim:
    input r0 as u32.private;
    async claim self.caller r0 into r1;
    output r1 as demo.aleo/claim.future;

finalize claim:
    input r0 as address.public;
    input r1 as u32.public;
    get.or_use principal[r0] 0u64 into r2;
    get.or_use rewards[r0] 0u64 into r3;
    get.or_use last_update_block[r0] r1 into r4;
    gte r1 r4 into r5;
    assert.eq r5 true;
    sub r1 r4 into r6;
    cast r6 into r7 as u64;
    mul r2 1200u64 into r8;
    mul r8 r7 into r9;
    div r9 315360000000u64 into r10;
    set 0u64 into rewards[r0];
    set r1 into last_update_block[r0];

function unstake:
    input r0 as u64.private;
    input r1 as u32.private;
    gt r0 0u64 into r2;
    assert.eq r2 true;
    async unstake self.caller r0 r1 into r3;
    output r3 as demo.aleo/unstake.future;

finalize unstake:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as u32.public;
    get.or_use principal[r0] 0u64 into r3;
    get.or_use rewards[r0] 0u64 into r4;
    get.or_use last_update_block[r0] r2 into r5;
    gte r3 r1 into r6;
    assert.eq r6 true;
    gte r2 r5 into r7;
    assert.eq r7 true;
    sub r2 r5 into r8;
    cast r8 into r9 as u64;
    mul r3 1200u64 into r10;
    mul r10 r9 into r11;
    div r11 315360000000u64 into r12;
    sub r3 r1 into r13;
    set r13 into principal[r0];
    add r4 r12 into r14;
    set r14 into rewards[r0];
    set r2 into last_update_block[r0];

constructor:
    assert.eq edition 0u16;
