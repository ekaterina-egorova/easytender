// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "hardhat/console.sol";
import "../contracts/EasyTender.sol";

contract EasyTenderTest {

    bytes constant ipfsHash = bytes("QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv");
    
    EasyTender easyTenderTest;
    function beforeAll () public {
        easyTenderTest = new EasyTender(10000, ipfsHash);
    }

    //function testByPrice () public {
    //    bytes32 offer1 = easyTenderTest.makeOffer(ipfsHash, 10000);
    //    bytes32 offer2 = easyTenderTest.makeOffer(ipfsHash, 9000);
    //    bytes32 offer3 = easyTenderTest.makeOffer(ipfsHash, 11000);

    //    easyTenderTest.setBiddingEndNow();
    //    easyTenderTest.play();

    //    Assert.equal(easyTenderTest.getWinnerPrice(), 9000, "Lowest price offer have to win");
    //    Assert.equal(easyTenderTest.getWinnerOfferId(), offer2, "Lowest price offer have to win");
    //}

    function testByVote () public {
        bytes32 offer1 = easyTenderTest.makeOffer(ipfsHash, 10000);
        bytes32 offer2 = easyTenderTest.makeOffer(ipfsHash, 10000);
        bytes32 offer3 = easyTenderTest.makeOffer(ipfsHash, 10000);

        easyTenderTest.voteOffer(offer2, true);

        easyTenderTest.setBiddingEndNow();
        easyTenderTest.play();

        Assert.equal(easyTenderTest.getWinnerPrice(), 10000, "Positive votes have to win");
        Assert.equal(easyTenderTest.getWinnerOfferId(), offer2, "Positive votes have to win");
    }

    function testByVote2 () public {
        bytes32 offer1 = easyTenderTest.makeOffer(ipfsHash, 10000);
        bytes32 offer2 = easyTenderTest.makeOffer(ipfsHash, 10000);
        bytes32 offer3 = easyTenderTest.makeOffer(ipfsHash, 10000);

        easyTenderTest.voteOffer(offer1, false);
        easyTenderTest.voteOffer(offer3, false);

        easyTenderTest.setBiddingEndNow();
        easyTenderTest.play();

        Assert.equal(easyTenderTest.getWinnerPrice(), 10000, "Negative votes have to loose");
        Assert.equal(easyTenderTest.getWinnerOfferId(), offer2, "Negative votes have to loose");
    }
}