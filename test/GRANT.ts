import { ethers } from "hardhat";
import { expect } from "chai";

describe("GirlScriptToken", function () {
    let Grant;
    let grant: any;
    let GirlScriptToken;
    let girlScriptToken: any;
    let owner: any;
    let addr1: any;
    let addr2: any;
    let addrs;

    beforeEach(async function () {
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        Grant = await ethers.getContractFactory("Grant");
        grant = await Grant.deploy();
    });

    describe("Deployment", function () {
        it("Should set the correct owner and GirlScriptToken address", async function () {
            expect(await grant.owner()).to.equal(owner.address);
        });
        it("Should start with currentID as 0", async function () {
            expect(await grant.getCurrentID()).to.equal(0);
        });

    });
    describe("Token Management", function () {
        it("Should allow buying GirlScriptToken", async function () {
          await grant.buyGirlScriptToken({ value: 100 });
        });
    
        it("Should revert if insufficient ether sent to buy GirlScriptToken", async function () {
          await expect(grant.buyGirlScriptToken({ value: 50 })).to.be.reverted;
        });
      });

});
