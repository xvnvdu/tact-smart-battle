    struct ProposalInit {
    master: Address;
    proposalId: Int as uint32;
}

message DeployNewProposal {
    votingEndingAt: Int as uint32;
}

contract ProposalMaster {
    // deploy
    proposalIdCounter: Int as uint32 = 0; 

    receive() { }

    receive(msg: DeployNewProposal) {
        require(now() <= msg.votingEndingAt, "Voting has already ended");
        
        deploy(DeployParameters{
           init: initOf Proposal(
                ProposalInit{
                master: myAddress(),
                proposalId: self.proposalIdCounter,
           }),
           value: ton("0.05"),
           body: msg.toCell(),
        });
        cashback(sender());

        self.proposalIdCounter += 1;
    }

    get fun nextProposalId(): Int {
        return self.proposalIdCounter;
    }
}

// ==============================================================================

message Vote {
    value: Bool;
}

struct ProposalState {
    yesCount: Int as uint32;
    noCount: Int as uint32;
    master: Address;
    proposalId: Int as uint32;
    votingEndingAt: Int as uint32;
}

contract Proposal {
    yesVotes: Int as uint32;
    noVotes: Int as uint32;
    alreadyVoted: map<Address, Bool> = emptyMap();
    master: Address;
    totalVotes: Int as uint32;
    proposalId: Int as uint32;
    votingEndingAt: Int as uint32;

    init(data: ProposalInit) {
        self.master = data.master;
        self.proposalId = data.proposalId;
        self.yesVotes = 0;
        self.noVotes = 0;
        self.totalVotes = 0;
        self.votingEndingAt = 0;
    }

    receive(msg: DeployNewProposal) {
        throwIf(2025, sender() != self.master);
        self.votingEndingAt = msg.votingEndingAt;
    }

    receive(msg: Vote) {
        require(now() <= self.votingEndingAt, "Voting has already ended" );
        require(self.totalVotes < 100, "Vote limit reached");
        require(self.alreadyVoted.exists(sender()) == false, "Already voted");

        if (msg.value) {
            self.yesVotes += 1;
        } else {
            self.noVotes += 1;
        }

        self.totalVotes += 1;
        self.alreadyVoted.set(sender(), true);
 
        //cashback(sender());
    }

    get fun proposalState(): ProposalState {
        return ProposalState{
            yesCount: self.yesVotes,
            noCount: self.noVotes,
            master: self.master,
            proposalId: self.proposalId,
            votingEndingAt: self.votingEndingAt,
        };
    }
}
