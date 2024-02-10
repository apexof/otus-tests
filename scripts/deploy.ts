import { ethers } from "hardhat";
// import { ERC20Token } from "../typechain-types/contracts/ERC20.sol";
// import { ERC20Token } from "../typechain-types";

async function main() {
  const contractFactory = await ethers.getContractFactory("Bank");
  const contract = await contractFactory.deploy();

  await contract.waitForDeployment();
  const address = await contract.getAddress()

  console.log("Contract deployed to:", address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
