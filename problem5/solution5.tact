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
    votes: Int as uint16 = 0;
    votingEndingAt: Int as uint32;
    alreadyVoted: map<Int as uint8, Bool> = emptyMap();

    init(data: Init) {
        self.votingEndingAt = data.votingEndingAt;
    }

    receive() { }

    receive(msg: Vote) {
        throwUnless(666, context().value > min(2 * ton("0.01") + ton("0.01") + 2 * context().readForwardFee(), ton("0.1")));
        throwUnless(777, now() <= self.votingEndingAt);
        throwUnless(888, self.alreadyVoted.exists(parseStdAddress(sender().asSlice()).address%256) == false);

        if (msg.value) {
            self.votes += 1;
        } else {
            self.votes += 1 << 8;
        }

        self.alreadyVoted.set(parseStdAddress(sender().asSlice()).address%256, true);
        cashback(sender());
    }

    get fun proposalState(): ProposalState {
        return ProposalState {
            yesCount: self.votes % 256,
            noCount: self.votes >> 8,
        };
    }
}
