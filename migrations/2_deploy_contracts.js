const Tokenship = artifacts.require('Tokenship')
const Marketplace = artifacts.require('Marketplace')


// use new instead of deployed
module.exports = async function(deployer) {
    deployer.deploy(Tokenship)
    const tokenship = await Tokenship.deployed()
    // console.log(tokenship.address)
    deployer.deploy(Marketplace, tokenship.address)
    // deployer.deploy(Marketplace)
}