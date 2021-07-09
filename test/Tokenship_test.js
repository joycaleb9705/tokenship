const { assert } = require('chai')

const Tokenship = artifacts.require('./Tokenship.sol')

require('chai')
    .use(require('chai-as-promised'))
    .should()

contract('Tokenship', (accounts) => {
    let contract

    before (async() => {
        contract = await Tokenship.deployed()
    })

    describe('deployment', async() => {
        it('deploys successfully', async() => {
            const address = contract.address
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
        })

        it('has a name', async() => {
            const name = await contract.name()
            assert.equal(name, 'Tokenship')
        })

        it('has a symbol', async() => {
            const symbol = await contract.symbol()
            assert.equal(symbol, 'TKS')
        })
    })

    describe('minting', async() => {

        it ('mints multiple TKSs', async() => {
            const nike = "NIKE"
            await contract.mint(accounts[1], 3, nike)
            const nikeSupply = await contract.getSupply(nike)
            assert.equal(nikeSupply, 3, 'supply should be 3')
            
            const nikeTks = await contract.getAllInfo(nike);            
            for (let i = 0; i < nikeTks.length; i++) {
                assert.equal(nikeTks[0][i], i, 'id should be ' + i)
                assert.equal(nikeTks[1][i], nike, 'association should be ' + nike)
            }
        })

        it ('mints more TKSs for another association', async() => {
            const cos = "COS"
            await contract.mint(accounts[1], 2, cos);
            const cosSupply = await contract.getSupply(cos);
            assert.equal(cosSupply, 2, 'supply should be 2')

            const cosTks = await contract.getAllInfo(cos)
            const n = await contract.totalSupply()
            for (let i = 0; i < cosTks.length; i++) {
                assert.equal(cosTks[0][i], i + n, 'id should be ' + (i + n))
                assert.equal(cosTks[1][i], cos, 'association should be ' + cos)
            }
        })

        it ('mints TKSs from non-minter role', async() => {
            const accountTwo = accounts[1];
            await contract.mint(accounts[0], 1, "NIKE", {from: accountTwo}).should.be.rejected;

            const totalSupply = await contract.totalSupply();
            assert.equal(totalSupply, 5, 'totalSupply should not have been changed')
        })
    })
})