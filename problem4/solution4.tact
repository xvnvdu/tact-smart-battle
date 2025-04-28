    struct ProposalInit {
        master: Address;
        proposalId: Int as uint32;           
    }
     
    message DeployNewProposal {
        votingEndingAt: Int as uint32;
    }
     
    message MyMessage {
        votingEndingAt: Int as uint32;
        userAddress: Address;
    }
     
    contract ProposalMaster {
        proposalIdCounter: Int as uint32 = 0; 
     
        receive() { 
            nativeReserve(ton("0.01"), 2);
            message(MessageParameters{
                value: 0,
                mode: SendRemainingBalance | SendIgnoreErrors,
                to: sender(),
            })
        }
     
        receive(msg: DeployNewProposal) {
            throwUnless(999, now() <= msg.votingEndingAt);
     
            deploy(DeployParameters{
               init: initOf Proposal(
                    ProposalInit{
                    master: myAddress(),
                    proposalId: self.proposalIdCounter,
               }),
               value: 0,
               mode: SendRemainingValue,
               body: MyMessage{
                votingEndingAt: msg.votingEndingAt,
                userAddress: sender(),
               }.toCell(),
            });
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
        master: Address;
        votes: Int as uint16 = 0;
        proposalId: Int as uint32;
        votingEndingAt: Int as uint32;
        alreadyVoted: map<Address, Bool> = emptyMap();
     
     
        init(data: ProposalInit) {
            if (sender() != data.master) {
                throw(2025);
            }
            self.master = data.master;
            self.proposalId = data.proposalId;
            self.votingEndingAt = 0;
        }
     
        receive(msg: MyMessage) {
                throwUnless(2025, sender() == self.master);
                self.votingEndingAt = msg.votingEndingAt;
                cashback(msg.userAddress);
            }
     
        receive(msg: Vote) {
            throwUnless(666, now() <= self.votingEndingAt);
            throwUnless(777, (self.votes % 256) + (self.votes >> 8) < 100);
            throwUnless(888, self.alreadyVoted.exists(sender()) == false);

            if (msg.value) {
                self.votes += 1;
            } else {
                self.votes += 1 << 8;
            }
     
            self.alreadyVoted.set(sender(), true);
            cashback(sender());
        }
     
        get fun proposalState(): ProposalState {
            return ProposalState{
                yesCount: self.votes % 256,
                noCount: self.votes >> 8,
                master: self.master,
                proposalId: self.proposalId,
                votingEndingAt: self.votingEndingAt,
            };
        }
    }