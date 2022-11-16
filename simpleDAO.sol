// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract simpleDAO {
    
    address payable public VendingMachineAddress;
    uint public voteEndTime;
    uint public DAObalance;
    uint decision;
    bool ended;
    address public chairperson;

    mapping(address=>uint) balances;
    mapping(address => Voter) public voters;

    
    error voteAlreadyEnded();
    error voteNotYetEnded();
    

    struct Voter {
        uint weight; 
        bool voted;  
        address delegate; 
        uint vote;   
    }

    struct Proposal {
        string name;   
        uint voteCount; 
    }
    Proposal[] public proposals;

  
    constructor(
        address payable _VendingMachineAddress,
        uint _voteTime,
        string[] memory proposalNames
    ) {
        VendingMachineAddress = _VendingMachineAddress;
        chairperson = msg.sender;
        
        voteEndTime = block.timestamp + _voteTime;
        voters[chairperson].weight = 1;

        for (uint i = 0; i < proposalNames.length; i++) {

            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }
    
    function DepositEth() public payable {
        DAObalance = address(this).balance;
        
        if (block.timestamp > voteEndTime)
            revert voteAlreadyEnded();
            
        require(DAObalance <= 1 ether, "1 Ether balance has been reached");
        
        DAObalance = address(this).balance;
        balances[msg.sender]+=msg.value;
    }
    
    
    

    function giveRightToVote(address voter) public {

        require(
            msg.sender == chairperson,
            "Only owner can give right to vote."
        );
        require(
            !voters[voter].voted,
            "The voter already voted."
        );
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }


    function countVote() public
            returns (uint winningProposal_)
            
    {
        require(
            block.timestamp > voteEndTime,
            "Vote not yet ended.");
        
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
                
                decision = winningProposal_;
                ended = true;
            }
        }
    }

    function withdraw(uint amount) public{
        if(balances[msg.sender]>=amount){
        balances[msg.sender]-=amount;
        payable(msg.sender).transfer(amount);
        DAObalance = address(this).balance;
        }
    }
   
    function EndVote() public {
        require(
            block.timestamp > voteEndTime,
            "Vote not yet ended.");
          
        require(
            ended == true,
            "Must count vote first");  
            
        require(
            DAObalance >= 1 ether,
            "Not enough balance in DAO required to buy cupcake. Members may withdraw deposited ether.");
            
        require(
            decision == 0,
            "DAO decided to not buy cupcakes. Members may withdraw deposited ether.");
            
            
        if (DAObalance  < 1 ether) revert();
            (bool success, ) = address(VendingMachineAddress).call{value: 1 ether}(abi.encodeWithSignature("purchase(uint256)", 1));
            require(success);
            
        DAObalance = address(this).balance;
  
        }
    
}