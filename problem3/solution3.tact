//
// Public solution template
//

message Vote {
    value: Bool;
}

struct ProposalState {
    yesCount: Int as uint32;
    noCount: Int as uint32;
}

struct Init {
    proposalId: Int as uint32;
    votingEndingAt: Int as uint32;
}

contract Proposal {
    votingEndingAt: Int as uint32;
    yesVotes: Int as uint32;
    noVotes: Int as uint32;
    alreadyVoted: map<Int, Bool> = emptyMap();

    init(data: Init) {
        self.votingEndingAt = data.votingEndingAt;
        self.yesVotes = 0;
        self.noVotes = 0;
    }

    // deploy
    receive() { }

    receive(msg: Vote) {
        require(now() <= self.votingEndingAt, "Voting has already ended" );
        let sndr = parseStdAddress(sender().asSlice());

        require(self.alreadyVoted.exists(sndr.address%256) == false,  "Already voted");

        if (msg.value) {
            self.yesVotes += 1;
        } else {
            self.noVotes += 1;
        }

        self.alreadyVoted.set(sndr.address%256, true);
        
        cashback(sender());
    }

    get fun proposalState(): ProposalState {
        return ProposalState {
            yesCount: self.yesVotes,
            noCount: self.noVotes,
        };
    }
}
