// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

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
    ) payable {
        biddingEnd = block.timestamp + biddingTime;
        tenderOwner = msg.sender;
        tenderIpfsHash = ipfsHash;
        console.log("EasyTender Contract created: owner=%s, biddingEnd=%s", tenderOwner, biddingEnd);
    }

    function play() external {
        console.log("Going to play");

        require(msg.sender == tenderOwner, "Only owner could play tender");
        console.log("Owner checked");
        require(!played, "Already played");
        console.log("Played flag checked");
        require(block.timestamp >= biddingEnd, "Bidding is still open");
        console.log("Time checked");

        if (offers.length == 0) {
            played = true;
            emit TenderCancelledEvent();
            return;
        } 

        console.log("There are offers to play");

        bytes32 bestOfferId;
        uint256 bestWeight = type(uint256).max;

        for (uint8 i = 0; i < offers.length; i++) {
            bytes32 offerId = offers[i];
            uint256 weight = offerById[offerId].weight;

            console.log("Checking offer: price=%s, weight=%s", 
                offerById[offerId].price, 
                offerById[offerId].weight);

            if (weight < bestWeight) {
                bestWeight = weight;
                bestOfferId = offerId;
            }
            console.log("Best weight=%s", bestWeight);
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

    function getWinnerOfferId() external view returns (bytes32 offerId) {
        require(block.timestamp >= biddingEnd, "Bidding is still open");
        return winner.id;
    }

    // Participant flow - offering and executing contract
    function makeOffer(bytes memory offerIpfsHash, uint256 price) external payable returns (bytes32 offerId) {
        require(block.timestamp < biddingEnd, "Bidding already closed");

        console.log("Making offer: price=%s, sender=%s", price, msg.sender);

        offerId = keccak256(abi.encode(msg.sender, offerIpfsHash, price));
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
        console.log("Voting with decision=%d", decision);
        Vote storage vote = voteByOfferIdBySender[msg.sender][offerId];
        require(!vote.voted, "Voter already voted");
        console.log("Already voted flag checked");
        require(block.timestamp < biddingEnd, "Voting already closed");
        console.log("Time checked");
        
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

        console.log("Offer acceptCount=%d, rejectCount=%d, weight=%d", offer.acceptCount, offer.rejectCount, offer.weight);

        address payable beneficiary = payable(msg.sender);
        beneficiary.transfer(voteReward);

        console.log("Payed reward %d to voter: %s", voteReward, beneficiary);

        emit VoteEvent(offerId, decision);
    }

    function setBiddingEndNow() public {
        biddingEnd = block.timestamp;
    }
}
