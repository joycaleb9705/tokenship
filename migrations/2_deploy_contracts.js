const Tokenship = artifacts.require('Tokenship')

module.exports = function(deployer) {
    deployer.deploy(Tokenship)
}