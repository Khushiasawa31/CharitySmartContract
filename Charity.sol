pragma solidity ^0.4.17;

contract Charity{
    
    struct CampaignRequest{
        string purpose;
        uint value;
        string need;
        address recipient;
        bool donationComplete;
        uint approvalCount;
        mapping(address=>bool) approvals;
    }
    
    address public campaignHead;
    uint public minimumDonation;
    mapping(address=> bool) donors;
    CampaignRequest[] public requests;
    uint public donorsCount;
    
    modifier restricted() {
        require(msg.sender == campaignHead);
        _;
    }
    
    function Charity(uint _min) public{
        campaignHead=msg.sender;
        minimumDonation= _min;
        donorsCount=0;
    }
    
    function donate() public payable{
        require(msg.value >= minimumDonation);
        
        donors[msg.sender]=true;
        donorsCount++;
    }
    
    function createCmapaignRequest(string _purpose, uint _value, address _recipient, string _need) public restricted{
        CampaignRequest memory newRequest= CampaignRequest({
            purpose: _purpose,
            value: _value,
            recipient: _recipient,
            donationComplete: false,
            approvalCount: 0
            need: _need
        });
        
        requests.push(newRequest);
    }

    function approveRequests(uint index) public {
        CampaignRequest storage request= requests[index]; 
        require(donors[msg.sender]);
        require(!request.approvals[msg.sender]);
        request.approvals[msg.sender]= true;
        request.approvalCount++;
        
    }
    
    function finalizeCampaignRequest(uint index) public restricted{
        CampaignRequest storage request= requests[index]; 
        require(request.approvalCount > (donorsCount/2));
        require(!request.donationComplete);
        request.donationComplete=true;
        request.recipient.transfer(request.value);
    }
    
}