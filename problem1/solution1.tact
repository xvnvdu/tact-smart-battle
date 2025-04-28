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
    alreadyVoted: map<Address, Int as uint8> = emptyMap();
    voteCount: Int as uint16 = 0;
 
    init(data: Init) {
        self.votingEndingAt = data.votingEndingAt;
    }
 
    receive() { }
 
    receive(msg: Vote) {
        throwUnless(666, now() <= self.votingEndingAt);
        throwUnless(777, (self.voteCount % 256) + (self.voteCount >> 8) < 100);
        throwUnless(888, self.alreadyVoted.exists(sender()) == false);
        
        if (msg.value) {
            self.voteCount += 1;
        } else {
            self.voteCount += 1 << 8;
        }
 
        self.alreadyVoted.set(sender(), 1);
        cashback(sender());
    }
 
    get fun proposalState(): ProposalState {
        return ProposalState {
            yesCount: self.voteCount % 256,
            noCount: self.voteCount >> 8,
        };
    }
}