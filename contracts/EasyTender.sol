// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract EasyTender {
    enum OfferState { New, Rejected, Accepted }

    mapping(bytes32 => Offer) offerById;
    mapping(address => mapping(bytes32=>Vote)) voteByOfferIdBySender;

    uint voteReward = 1;

    event TenderCancelledEvent ();

    event TenderPlayedEvent (
        address owner,
        bytes ipfsHash,
        Offer winner
    );

    event OfferEvent (
        bytes32 id,
        OfferState state
    );

    event VoteEvent (
        bytes32 offerId,
        bool decision
    );

    struct Offer {
        bytes32 id;
        address sender;
        bytes ipfsHash;
        uint256 price;
        uint256 weight;
        uint16 acceptCount;
        uint16 rejectCount;
    }

    struct Vote {
        bool voted;
        bool decision;
    }

    address public tenderOwner;
    uint public biddingEnd;
    bytes public tenderIpfsHash;
    bytes32[] offers;

    Offer winner;
    bool played = false;

    constructor(
        uint biddingTime,
        bytes memory ipfsHash
    ) {
        biddingEnd = block.timestamp + biddingTime;
        tenderOwner = msg.sender;
        tenderIpfsHash = ipfsHash;
    }

    function play() external {
        require(msg.sender == tenderOwner, "Only owner could play tender");
        require(!played, "Already played");
        require(block.timestamp >= biddingEnd, "Bidding is still open");

        if (offers.length == 0) {
            emit TenderCancelledEvent();
            return;
        } 

        bytes32 bestOfferId;
        uint256 bestWeight = type(uint256).max;

        for (uint8 i = 0; i < offers.length; i++) {
            bytes32 offerId = offers[i];
            uint256 weight = offerById[offerId].weight;
            if (weight < bestWeight) {
                bestWeight = weight;
                bestOfferId = offerId;
            }
        }

        winner = offerById[bestOfferId];

        for (uint8 i = 0; i < offers.length; i++) {
            bytes32 offerId = offers[i];
            if (offerId != bestOfferId) {
                emit OfferEvent(offerId, OfferState.Rejected);
            } 
        }

        emit OfferEvent(bestOfferId, OfferState.Accepted);

        emit TenderPlayedEvent(tenderOwner, tenderIpfsHash, winner);

        played = true;
    }

    function getWinnerPrice() external view returns (uint256 winnerPrice) {
        require(block.timestamp >= biddingEnd, "Bidding is still open");
        return winner.price;
    }

    // Participant flow - offering and executing contract
    function makeOffer(bytes memory offerIpfsHash, uint256 price) external payable {
        require(block.timestamp < biddingEnd, "Bidding already closed");

        bytes32 offerId = keccak256(abi.encode(msg.sender, offerIpfsHash));
        Offer storage offer = offerById[offerId];
        offer.id = offerId;
        offer.sender = msg.sender; 
        offer.ipfsHash = offerIpfsHash;
        offer.price = price;
        offer.weight = price;
        offer.acceptCount = 0;
        offer.rejectCount = 0;

        offers.push(offerId);

        emit OfferEvent(offerId, OfferState.New);
    }

    // Researchers flow - reserching offer and voting for reward
    function voteOffer(bytes32 offerId, bool decision) external {
        Vote storage vote = voteByOfferIdBySender[msg.sender][offerId];
        require(!vote.voted, "Voter already voted");
        require(block.timestamp < biddingEnd, "Voting already closed");
        
        vote.voted = true;
        vote.decision = decision;

        Offer storage offer = offerById[offerId];

        if (decision) {
            offer.acceptCount = offer.acceptCount + 1;
            offer.weight = (offer.weight * 101)/100;
        } else {
            offer.rejectCount = offer.rejectCount + 1;
            offer.weight = (offer.weight * 985)/1000;
        }

        address payable beneficiary = payable(msg.sender);
        beneficiary.transfer(voteReward);

        emit VoteEvent(offerId, decision);
    }
}
