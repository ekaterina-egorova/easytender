/* eslint-disable no-undef */
// Right click on the script name and hit "Run" to execute
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("EasyTender", function () {
  it("test get tender", async function () {
    const EasyTender = await ethers.getContractFactory("EasyTender");
    const easyContract = await EasyTender.deploy();
    await easyContract.deployed();
    console.log("Easytender deployed at:" + easyContract.address);
    expect(await easyContract.getTender(1)).to.equal(NaN);
  });
  it("test updating and retrieving updated value", async function () {
    const EasyTender = await ethers.getContractFactory("EasyTender");
    const easyContract = await EasyTender.deploy();
    await easyContract.deployed();
    const easyContract2 = await ethers.getContractAt("EasyTender", easyContract.address);
    const setValue = await easyContract2.newTender(1);
    await setValue.wait();
    expect((await easyContract2.getTender(1)).ipfsHash).to.equal(1);
  });
});
