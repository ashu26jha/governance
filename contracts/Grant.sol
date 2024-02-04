// SPDX-License-Identifier: GPL-3.0-only

pragma solidity ^0.8.20;

import "contracts/Token.sol";

error Grant__NOT_ENOUGH_AMOUNT_SENT();
error Grant__NOT_ENOUGH_TOKENS();
error Grant__ALREADY_VOTED();
error Grant__PROPOSER_CANNOT_VOTE();
error Grant__EXECUTED();
error Grant__TIME_LAPSE();
error Grant__UNAUTHORIZED();
error Grant__TIME_REMAINING();

contract Grant  {

    struct Proposal{
        uint256 id;
        address proposer;
        string descriptionLink;
        uint256 amountNeeded;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 startTime;
        uint256 endTime;
        bool executed;
        mapping(address => bool) voted;
        mapping(address => uint256) amountStaked;
        address [] voters;
    }
    
    address public immutable girlscriptAddress;
    address public immutable owner;
    uint256 public immutable priceGirlScriptToken = 100; 

    uint256 public currentID = 0;
    mapping(uint256 => Proposal) private proposals;

    constructor()   {
        GirlScriptToken tokenaddress = new GirlScriptToken(address(this)) ;
        girlscriptAddress = address(tokenaddress);
        owner = msg.sender;
    }

    event ProposalCreated(uint256 indexed id, address indexed proposer, string link);
    event Voted(uint256 indexed id, address indexed voter, bool inSupport, uint256 votes);


    function createProposal(
        uint256 amountNeeded,
        string memory descLink,
        uint256 duration
    ) public {

        Proposal storage newProposal = proposals[currentID];

        newProposal.id = currentID;
        newProposal.proposer = msg.sender;
        newProposal.descriptionLink = descLink;
        newProposal.amountNeeded = amountNeeded;
        newProposal.startTime = block.timestamp;
        newProposal.endTime = block.timestamp + duration;
        newProposal.executed = false;

        emit ProposalCreated(currentID, msg.sender, descLink);

        currentID++;
    }

    function voteProposal (
        uint256 id,
        uint256 tokenStaked,
        bool inSupport
    ) public {

        GirlScriptToken contractToken = GirlScriptToken(girlscriptAddress);

        if(contractToken.balanceOf(msg.sender) > tokenStaked){
            revert Grant__NOT_ENOUGH_TOKENS();
        }
        
        Proposal storage proposal =  proposals[id];

        if(proposal.voted[msg.sender]==true){
            revert Grant__ALREADY_VOTED();
        }
        if(msg.sender == proposal.proposer){
            revert Grant__PROPOSER_CANNOT_VOTE();
        }
        if(proposal.executed == true){
            revert Grant__EXECUTED();
        }

        // if(block.timestamp > proposal.endTime){
        //     revert Grant__TIME_LAPSE();
        // }

        contractToken.transferFrom(msg.sender, address(this), tokenStaked);

        if (inSupport == true){
            proposal.forVotes += tokenStaked;
            proposal.amountStaked[msg.sender] = tokenStaked;
        }
        else{
            proposal.againstVotes += tokenStaked;
            proposal.amountStaked[msg.sender] = tokenStaked;
        }

        proposal.voters.push(msg.sender);

        emit Voted(id, msg.sender, inSupport, tokenStaked);
    }

    function executeProposal (uint256 id) public {
        Proposal storage proposal =  proposals[id];
        if(proposal.executed == true){
            revert Grant__EXECUTED();
        }
        if(proposal.proposer == msg.sender || msg.sender == owner){
            if(proposal.forVotes > proposal.againstVotes){
                GirlScriptToken contractToken = GirlScriptToken(girlscriptAddress);
                contractToken.transfer(proposal.proposer, proposal.amountNeeded);
            }
            proposal.executed = true;
            
        }
        else{
            revert Grant__UNAUTHORIZED();
        }
        
        
    }

    // Used to buy GirlScript Token
    function buyGirlScriptToken () public payable  {
        if(msg.value < priceGirlScriptToken){
            revert Grant__NOT_ENOUGH_AMOUNT_SENT() ;
        }
        GirlScriptToken contractToken = GirlScriptToken(girlscriptAddress);
        contractToken.mint(msg.sender, 100);
    }

    function getProposer(uint256 id) public view returns (address){
        return proposals[id].proposer;
    }

    function getCurrentID() public view returns (uint256){
        return currentID;
    }

    function getDescLink(uint256 id) public view returns (string memory){
        return proposals[id].descriptionLink;
    }

    function getForVotes(uint256 id) public view returns (uint256){
        return proposals[id].forVotes;
    }

    function getAgainstVotes(uint256 id) public view returns (uint256){
        return proposals[id].againstVotes;
    }

    function getStartTime(uint256 id) public view returns (uint256){
        return proposals[id].startTime;
    }

    function getEndTime(uint256 id) public view returns (uint256){
        return proposals[id].endTime;
    }

    function getExecuted(uint256 id) public view returns (bool){
        return proposals[id].executed;
    }

    function getVoted(uint256 id, address voter) public view returns (bool){
        return proposals[id].voted[voter];
    }

    function getAmountStaked(uint256 id, address voter) public view returns (bool){
        return proposals[id].voted[voter];
    }

    function getGirlScriptAddress() public view returns (address){
        return girlscriptAddress;
    }

}
