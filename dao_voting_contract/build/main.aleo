import credits.aleo;
program dao_voting_contract.aleo;

struct Proposal:
    recipient as address;
    amount as u64;
    vote_count as u8;
    reject_count as u8;
    is_approved as boolean;
    is_executed as boolean;
    is_active as boolean;

struct VoteKey:
    member as address;
    proposal_id as field;

mapping proposals:
    key as field.public;
    value as Proposal.public;

mapping has_voted:
    key as field.public;
    value as boolean.public;

mapping proposal_counter:
    key as boolean.public;
    value as field.public;

function create_proposal:
    input r0 as address.private;
    input r1 as u64.private;
    assert.eq self.caller aleo1nz5cpl2mmu3hmzmxamp2g2fk2zu46ha53r566nc5tjzgwl4qmc8se2z4yv;
    gt r1 0u64 into r2;
    assert.eq r2 true;
    cast r0 r1 0u8 0u8 false false true into r3 as Proposal;
    async create_proposal r3 into r4;
    output r4 as dao_voting_contract.aleo/create_proposal.future;

finalize create_proposal:
    input r0 as Proposal.public;
    get.or_use proposal_counter[true] 0field into r1;
    add r1 1field into r2;
    set r2 into proposal_counter[true];
    set r0 into proposals[r2];

function vote:
    input r0 as field.private;
    input r1 as boolean.private;
    is.eq self.caller aleo13hfyln9uyq7epkqg4hcmlrfml4v0nl4ze7zqstd6wy25tqej3syqcs699l into r2;
    is.eq self.caller aleo1xgg3n4qd5tczru5xdarytkdsww7hzd0fpzq2vl33z0cdatghvyqqcgm5yg into r3;
    or r2 r3 into r4;
    is.eq self.caller aleo1ulp725qyzksnnwe8cpzy36uj0q39ev9fta7w52u45g0sa8qa258snwn7u2 into r5;
    or r4 r5 into r6;
    assert.eq r6 true;
    async vote r0 self.caller r1 into r7;
    output r7 as dao_voting_contract.aleo/vote.future;

finalize vote:
    input r0 as field.public;
    input r1 as address.public;
    input r2 as boolean.public;
    cast r1 r0 into r3 as VoteKey;
    hash.bhp256 r3 into r4 as field;
    get.or_use has_voted[r4] false into r5;
    not r5 into r6;
    assert.eq r6 true;
    set true into has_voted[r4];
    get proposals[r0] into r7;
    assert.eq r7.is_active true;
    not r7.is_executed into r8;
    assert.eq r8 true;
    add r7.vote_count 1u8 into r9;
    ternary r2 r9 r7.vote_count into r10;
    add r7.reject_count 1u8 into r11;
    ternary r2 r7.reject_count r11 into r12;
    gte r10 2u8 into r13;
    gte r12 2u8 into r14;
    not r14 into r15;
    and r13 r15 into r16;
    cast r7.recipient r7.amount r10 r12 r16 false r15 into r17 as Proposal;
    set r17 into proposals[r0];

function execute_withdrawal:
    input r0 as field.private;
    input r1 as address.private;
    input r2 as u64.private;
    assert.eq self.caller aleo1ekza6x7zftmgx9snh5j3h7ds0tw8qmzugh7sr0sfu72cvfe87yzsuxsewm;
    call credits.aleo/transfer_public r1 r2 into r3;
    async execute_withdrawal r0 r1 r2 r3 into r4;
    output r4 as dao_voting_contract.aleo/execute_withdrawal.future;

finalize execute_withdrawal:
    input r0 as field.public;
    input r1 as address.public;
    input r2 as u64.public;
    input r3 as credits.aleo/transfer_public.future;
    get proposals[r0] into r4;
    assert.eq r4.is_approved true;
    assert.eq r4.is_active true;
    not r4.is_executed into r5;
    assert.eq r5 true;
    assert.eq r4.recipient r1;
    assert.eq r4.amount r2;
    await r3;
    cast r4.recipient r4.amount r4.vote_count r4.reject_count r4.is_approved true false into r6 as Proposal;
    set r6 into proposals[r0];

function cancel_proposal:
    input r0 as field.private;
    assert.eq self.caller aleo1nz5cpl2mmu3hmzmxamp2g2fk2zu46ha53r566nc5tjzgwl4qmc8se2z4yv;
    async cancel_proposal r0 into r1;
    output r1 as dao_voting_contract.aleo/cancel_proposal.future;

finalize cancel_proposal:
    input r0 as field.public;
    get proposals[r0] into r1;
    assert.eq r1.is_active true;
    not r1.is_executed into r2;
    assert.eq r2 true;
    cast r1.recipient r1.amount r1.vote_count r1.reject_count false false false into r3 as Proposal;
    set r3 into proposals[r0];

constructor:
    assert.eq edition 0u16;
