import { ethers } from "hardhat"
async function main {
    // const FTToken = await ethers.getContractFactory("FertilizerToken")
    const FODToken = await ethers.getContractFactory("FoodToken")

    // const FTTokendeployed = await FTToken.deploy()
    const FODTokendeployed = await FODToken.deploy()

    // await FTTokendeployed.deployed()
    await FODTokendeployed.deployed()

    console.log("Contract deployed to: ", contract.address)
}

const runMain = async () => {
    try {
        await main()
        process.exit(0)
    } catch (error) {
        console.log(error)
        process.exit(1)
    }
}
