import credits.aleo;
program dao.aleo;

struct Proposal:
    recipient as address;
    amount as u64;
    vote_count as u8;
    reject_count as u8;
    is_approved as boolean;
    is_executed as boolean;
    is_active as boolean;

mapping proposals:
    key as field.public;
    value as Proposal.public;

mapping has_voted:
    key as field.public;
    value as boolean.public;

function create_proposal:
    input r0 as field.private;
    input r1 as address.private;
    input r2 as u64.private;
    assert.eq self.caller aleo1nz5cpl2mmu3hmzmxamp2g2fk2zu46ha53r566nc5tjzgwl4qmc8se2z4yv;
    gt r2 0u64 into r3;
    assert.eq r3 true;
    cast r1 r2 0u8 0u8 false false true into r4 as Proposal;
    async create_proposal r0 r4 into r5;
    output r5 as dao.aleo/create_proposal.future;

finalize create_proposal:
    input r0 as field.public;
    input r1 as Proposal.public;
    contains proposals[r0] into r2;
    not r2 into r3;
    assert.eq r3 true;
    set r1 into proposals[r0];

function vote:
    input r0 as field.private;
    input r1 as boolean.private;
    is.eq self.caller aleo13hfyln9uyq7epkqg4hcmlrfml4v0nl4ze7zqstd6wy25tqej3syqcs699l into r2;
    is.eq self.caller aleo1xgg3n4qd5tczru5xdarytkdsww7hzd0fpzq2vl33z0cdatghvyqqcgm5yg into r3;
    or r2 r3 into r4;
    is.eq self.caller aleo1ulp725qyzksnnwe8cpzy36uj0q39ev9fta7w52u45g0sa8qa258snwn7u2 into r5;
    or r4 r5 into r6;
    assert.eq r6 true;
    hash.bhp256 self.caller into r7 as field;
    add r7 r0 into r8;
    async vote r0 r8 r1 into r9;
    output r9 as dao.aleo/vote.future;

finalize vote:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as boolean.public;
    get.or_use has_voted[r1] false into r3;
    not r3 into r4;
    assert.eq r4 true;
    set true into has_voted[r1];
    get proposals[r0] into r5;
    assert.eq r5.is_active true;
    not r5.is_executed into r6;
    assert.eq r6 true;
    add r5.vote_count 1u8 into r7;
    ternary r2 r7 r5.vote_count into r8;
    add r5.reject_count 1u8 into r9;
    ternary r2 r5.reject_count r9 into r10;
    gte r8 2u8 into r11;
    gte r10 2u8 into r12;
    not r12 into r13;
    cast r5.recipient r5.amount r8 r10 r11 false r13 into r14 as Proposal;
    set r14 into proposals[r0];

function execute_withdrawal:
    input r0 as field.private;
    input r1 as address.private;
    input r2 as u64.private;
    assert.eq self.caller aleo1ekza6x7zftmgx9snh5j3h7ds0tw8qmzugh7sr0sfu72cvfe87yzsuxsewm;
    call credits.aleo/transfer_public r1 r2 into r3;
    async execute_withdrawal r0 r1 r2 r3 into r4;
    output r4 as dao.aleo/execute_withdrawal.future;

finalize execute_withdrawal:
    input r0 as field.public;
    input r1 as address.public;
    input r2 as u64.public;
    input r3 as credits.aleo/transfer_public.future;
    get proposals[r0] into r4;
    assert.eq r4.is_approved true;
    not r4.is_executed into r5;
    assert.eq r5 true;
    assert.eq r4.is_active true;
    assert.eq r4.recipient r1;
    assert.eq r4.amount r2;
    await r3;
    cast r4.recipient r4.amount r4.vote_count r4.reject_count r4.is_approved true false into r6 as Proposal;
    set r6 into proposals[r0];

function cancel_proposal:
    input r0 as field.private;
    assert.eq self.caller aleo1nz5cpl2mmu3hmzmxamp2g2fk2zu46ha53r566nc5tjzgwl4qmc8se2z4yv;
    async cancel_proposal r0 into r1;
    output r1 as dao.aleo/cancel_proposal.future;

finalize cancel_proposal:
    input r0 as field.public;
    get proposals[r0] into r1;
    not r1.is_executed into r2;
    assert.eq r2 true;
    assert.eq r1.is_active true;
    cast r1.recipient r1.amount r1.vote_count r1.reject_count r1.is_approved false false into r3 as Proposal;
    set r3 into proposals[r0];
