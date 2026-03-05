import credits.aleo;
import dao.aleo;
program test_dao.aleo;

struct Proposal:
    recipient as address;
    amount as u64;
    vote_count as u8;
    reject_count as u8;
    is_approved as boolean;
    is_executed as boolean;
    is_active as boolean;

function test_create_proposal:
    call dao.aleo/create_proposal 1field aleo13hfyln9uyq7epkqg4hcmlrfml4v0nl4ze7zqstd6wy25tqej3syqcs699l 5000u64 into r0;
    async test_create_proposal r0 into r1;
    output r1 as test_dao.aleo/test_create_proposal.future;

finalize test_create_proposal:
    input r0 as dao.aleo/create_proposal.future;
    await r0;

function test_member1_vote_yes:
    call dao.aleo/vote 1field true into r0;
    async test_member1_vote_yes r0 into r1;
    output r1 as test_dao.aleo/test_member1_vote_yes.future;

finalize test_member1_vote_yes:
    input r0 as dao.aleo/vote.future;
    await r0;

function test_member2_vote_yes:
    call dao.aleo/vote 1field true into r0;
    async test_member2_vote_yes r0 into r1;
    output r1 as test_dao.aleo/test_member2_vote_yes.future;

finalize test_member2_vote_yes:
    input r0 as dao.aleo/vote.future;
    await r0;

function test_execute_withdrawal:
    call dao.aleo/execute_withdrawal 1field aleo13hfyln9uyq7epkqg4hcmlrfml4v0nl4ze7zqstd6wy25tqej3syqcs699l 5000u64 into r0;
    async test_execute_withdrawal r0 into r1;
    output r1 as test_dao.aleo/test_execute_withdrawal.future;

finalize test_execute_withdrawal:
    input r0 as dao.aleo/execute_withdrawal.future;
    await r0;

function test_member_vote_no:
    call dao.aleo/vote 2field false into r0;
    async test_member_vote_no r0 into r1;
    output r1 as test_dao.aleo/test_member_vote_no.future;

finalize test_member_vote_no:
    input r0 as dao.aleo/vote.future;
    await r0;

function test_cancel_proposal:
    call dao.aleo/cancel_proposal 2field into r0;
    async test_cancel_proposal r0 into r1;
    output r1 as test_dao.aleo/test_cancel_proposal.future;

finalize test_cancel_proposal:
    input r0 as dao.aleo/cancel_proposal.future;
    await r0;
