import { Account, ProgramManager, AleoNetworkClient, NetworkRecordProvider } from "@provablehq/sdk";

// ── Config ──────────────────────────────────────────────
const NETWORK = "testnet";
const ENDPOINT = "https://api.explorer.provable.com/v1";
const PROGRAM_ID = "dao_voting_contract.aleo";

// Private keys for each role
const ADMIN_PRIVATE_KEY = "APrivateKey1zkpDMU9x4t1ruZadjnYVAp21uED3qhTshqFeySQXP2K2iSw";
const MEMBER_1_PRIVATE_KEY = "YOUR_MEMBER_1_PRIVATE_KEY";
const MEMBER_2_PRIVATE_KEY = "YOUR_MEMBER_2_PRIVATE_KEY";
const TREASURY_PRIVATE_KEY = "YOUR_TREASURY_PRIVATE_KEY";

// ── Helper: create program manager for a given private key ──
function getManager(privateKey) {
    const account = new Account({ privateKey });
    const networkClient = new AleoNetworkClient(ENDPOINT);
    const recordProvider = new NetworkRecordProvider(account, networkClient);
    const manager = new ProgramManager(ENDPOINT, undefined, recordProvider);
    manager.setAccount(account);
    return manager;
}

// ── 1. Create Proposal (ADMIN only) ─────────────────────
async function createProposal(recipient, amount) {
    console.log("Creating proposal...");
    const manager = getManager(ADMIN_PRIVATE_KEY);

    const tx = await manager.execute({
        programName: PROGRAM_ID,
        functionName: "create_proposal",
        inputs: [recipient, `${amount}u64`],
        fee: 0.5,
        privateFee: false,
    });

    console.log("✅ Proposal created! TX ID:", tx);
    return tx;
}

// ── 2. Vote (MEMBER only) ────────────────────────────────
async function vote(memberPrivateKey, proposalId, approve) {
    console.log(`Voting ${approve ? "approve" : "reject"} on proposal ${proposalId}...`);
    const manager = getManager(memberPrivateKey);

    const tx = await manager.execute({
        programName: PROGRAM_ID,
        functionName: "vote",
        inputs: [`${proposalId}field`, approve.toString()],
        fee: 0.5,
        privateFee: false,
    });

    console.log("✅ Vote cast! TX ID:", tx);
    return tx;
}

// ── 3. Cancel Proposal (ADMIN only) ─────────────────────
async function cancelProposal(proposalId) {
    console.log(`Cancelling proposal ${proposalId}...`);
    const manager = getManager(ADMIN_PRIVATE_KEY);

    const tx = await manager.execute({
        programName: PROGRAM_ID,
        functionName: "cancel_proposal",
        inputs: [`${proposalId}field`],
        fee: 0.5,
        privateFee: false,
    });

    console.log("✅ Proposal cancelled! TX ID:", tx);
    return tx;
}

// ── 4. Execute Withdrawal (TREASURY only) ───────────────
async function executeWithdrawal(proposalId, recipient, amount) {
    console.log(`Executing withdrawal for proposal ${proposalId}...`);
    const manager = getManager(TREASURY_PRIVATE_KEY);

    const tx = await manager.execute({
        programName: PROGRAM_ID,
        functionName: "execute_withdrawal",
        inputs: [`${proposalId}field`, recipient, `${amount}u64`],
        fee: 0.5,
        privateFee: false,
    });

    console.log("✅ Withdrawal executed! TX ID:", tx);
    return tx;
}

// ── 5. Read Mappings (no transaction needed) ─────────────
async function getProposal(proposalId) {
    const networkClient = new AleoNetworkClient(ENDPOINT);
    const result = await networkClient.getProgramMappingValue(
        PROGRAM_ID,
        "proposals",
        `${proposalId}field`
    );
    console.log("Proposal:", result);
    return result;
}

async function getProposalCounter() {
    const networkClient = new AleoNetworkClient(ENDPOINT);
    const result = await networkClient.getProgramMappingValue(
        PROGRAM_ID,
        "proposal_counter",
        "true"
    );
    console.log("Proposal Counter:", result);
    return result;
}

async function hasVoted(member, proposalId) {
    const networkClient = new AleoNetworkClient(ENDPOINT);

    // Recreate the vote_key hash — same logic as in the contract
    const voteKey = `{ member: ${member}, proposal_id: ${proposalId}field }`;
    const result = await networkClient.getProgramMappingValue(
        PROGRAM_ID,
        "has_voted",
        voteKey
    );
    console.log("Has voted:", result);
    return result;
}

// ── Main: example flow ───────────────────────────────────
async function main() {
    const RECIPIENT = "aleo13hfyln9uyq7epkqg4hcmlrfml4v0nl4ze7zqstd6wy25tqej3syqcs699l";
    const AMOUNT = 500;

    // 1. Admin creates a proposal
    await createProposal(RECIPIENT, AMOUNT);

    // wait for tx to confirm
    await new Promise(r => setTimeout(r, 15000));

    // 2. Check proposal counter
    await getProposalCounter();

    // 3. Read proposal
    await getProposal(1);

    // 4. Member 1 votes approve
    await vote(MEMBER_1_PRIVATE_KEY, 1, true);
    await new Promise(r => setTimeout(r, 15000));

    // 5. Member 2 votes approve — reaches majority
    await vote(MEMBER_2_PRIVATE_KEY, 1, true);
    await new Promise(r => setTimeout(r, 15000));

    // 6. Read proposal again — should show is_approved: true
    await getProposal(1);

    // 7. Treasury executes withdrawal
    await executeWithdrawal(1, RECIPIENT, AMOUNT);
}

main().catch(console.error);