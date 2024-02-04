import { ethers } from "hardhat";

async function main() {
  const Grant = await ethers.getContractFactory("Grant");
  const grant = await Grant.deploy();
  console.log("Grant contract deployed to:", await grant.getAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
