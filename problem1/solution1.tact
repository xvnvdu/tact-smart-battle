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
    totalVotes: Int as uint32;
    alreadyVoted: map<Address, Bool> = emptyMap();

    init(data: Init) {
        self.votingEndingAt = data.votingEndingAt;
        self.yesVotes = 0;
        self.noVotes = 0;
        self.totalVotes = 0;
    }

    // deploy
    receive() { }

    receive(msg: Vote) {
        require(now() <= self.votingEndingAt, "Voting has already ended" );
        require(self.totalVotes < 100, "Vote limit reached");
        require(self.alreadyVoted.exists(sender()) == false,  "Already voted");

        if (msg.value) {
            self.yesVotes += 1;
        } else {
            self.noVotes += 1;
        }

        self.totalVotes += 1;
        self.alreadyVoted.set(sender(), true);
        
        // message(MessageParameters{
        //     to: sender(),
        //     value: 0,
        //     mode: SendRemainingBalance,
        // });
        cashback(sender());
    }

    get fun proposalState(): ProposalState {
        return ProposalState {
            yesCount: self.yesVotes,
            noCount: self.noVotes,
        };
    }
}
