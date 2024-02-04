import { ethers } from "hardhat";
import { expect } from "chai";

describe("GirlScriptToken", function () {
  let GirlScriptToken;
  let girlScriptToken: any;
  let owner: any;
  let addr1: any;
  let addr2: any;
  let addrs;

  beforeEach(async function () {
    GirlScriptToken = await ethers.getContractFactory("GirlScriptToken");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    girlScriptToken = await GirlScriptToken.deploy(owner);
    // await girlScriptToken.deployed();
  });

  describe("Deployment", function () {
    it("Should set the correct name and symbol", async function () {
      expect(await girlScriptToken.name()).to.equal("GirlScript Token");
      expect(await girlScriptToken.symbol()).to.equal("GTK");
    });

    it("Should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await girlScriptToken.balanceOf(owner.address);
      expect(await girlScriptToken.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Minting", function () {
    it("Should allow the owner to mint new tokens", async function () {
      const mintAmount = ethers.parseEther("1000");
      await girlScriptToken.mint(owner.address, mintAmount);
      expect(await girlScriptToken.balanceOf(owner.address)).to.equal(mintAmount);
    });

    it("Should not allow minting by non-owner", async function () {
      const mintAmount = ethers.parseEther("1000"); // Minting 1000 tokens
      await expect(girlScriptToken.connect(addr1).mint(addr2.address, mintAmount)).to.be.reverted;
    });
  });
});
