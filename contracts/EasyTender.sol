// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract EasyTender {
    enum TenderState { New, Played, Executed }
    enum ContractState { Aggreed, Executed, Cancelled }
    enum OfferState { New, Rejected, Accepted }

    mapping(bytes32 => Tender) tenders;
    mapping(bytes32 => Offer) offers;
    mapping(bytes32 => TenderContract) contracts;
    mapping(bytes32 => Vote) tenderVotes;

    uint256 voteReward = 10;

    event NewTenderEvent (
        bytes32 id,
        address sender,
        bytes32 ipfsHash
    );

    event NewOfferEvent (
        bytes32 id,
        bytes32 tenderId,
        address sender,
        bytes32 ipfsHash
    );

    event NewVoteEvent (
        bytes32 id,
        bytes32 tenderId,
        bytes32 offerId,
        address sender
    );

    struct Tender {
        bytes32 id;
        address sender;
        bytes32 ipfsHash;
        TenderState state;
    }

    struct Offer {
        bytes32 id;
        address sender;
        string ipfsHash;
        uint256 price;
        OfferState state;
    }

    struct Vote {
        address sender;
        bool desicion;
    }

    struct TenderContract {
        bytes32 tenderId;
        uint256 offerIndex;
        ContractState state;
    }

    function getTender(bytes32 tenderId) public view returns (Tender memory tender) {
        return tenders[tenderId];
    }

    // Owner flow - starting and accepting tender, pays for contract execution
    function newTender(bytes32 ipfsHash) public returns (bytes32 tenderId) {
        tenderId = keccak256(abi.encode(msg.sender, ipfsHash));
       
        Tender storage tender = tenders[tenderId];
        tender.sender = msg.sender;
        tender.ipfsHash = ipfsHash;
        tender.state = TenderState.New;

        emit NewTenderEvent(tenderId, msg.sender, ipfsHash);
    }

    //function aceptOffer(bytes32 tenderId, uint256 offerIndex) public returns (bytes32 contractId) {
    //    Tender storage tender = tenders[tenderId];
    //    tender.offers[offerIndex].state = OfferState.Accepted;
    //    tender.state = TenderState.Played;
    //    contractId = keccak256(abi.encode(msg.sender, tenderId, offerIndex));
    //    TenderContract storage tenderContract = contracts[contractId];
    //    tenderContract.tenderId = tenderId;
    //    tenderContract.offerIndex = offerIndex;
    //    tenderContract.state = ContractState.Aggreed;
    //}

    //function rejectOffer(bytes32 tenderId, uint256 offerIndex) public {
    //    Tender storage tender = tenders[tenderId];
    //    tender.offers[offerIndex].state = OfferState.Rejected;
    //}

    // // Participant flow - offering and executing contract
    //function sendOffer(bytes32 tenderId, string memory docKey, uint256 price) public {
    //    Tender storage tender = tenders[tenderId];
    //    tender.offers[tender.offerSize++] = Offer(msg.sender, docKey, price, OfferState.New);
    //}

    //function executeContract(bytes32 contractId) public {
    //    TenderContract storage tenderContract = contracts[contractId];
    //    tenderContract.state = ContractState.Executed;
    //    Tender storage tender = tenders[tenderContract.tenderId];
    //    tender.state = TenderState.Executed;
    //    Offer memory offer = tender.offers[tenderContract.offerIndex];
    //    address payable beneficiary = payable(offer.sender);
    //    beneficiary.transfer(offer.price);
    //}

    // Researchers flow - voting for reward
    //function voteTender(bytes32 tenderId, bool decision) public {
    //    Tender storage tender = tenders[tenderId];
    //    tender.votes[tender.voteSize++] = Vote(msg.sender, decision);

    //    payable(msg.sender).transfer(voteReward);
    //}

    //function voteOffer(bytes32 offerId, bool decision) public {
    //    Tender storage tender = tenders[offerId];
    //    tender.votes[tender.voteSize++] = Vote(msg.sender, decision);

    //    payable(msg.sender).transfer(voteReward);
    //}
    // fun vote(ParticipantVote) return Reward
    // fun vote(OwnerVote) return Reward
}
