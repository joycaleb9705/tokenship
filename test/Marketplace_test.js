const { assert } = require('chai')

const Tokenship = artifacts.require('./Tokenship.sol')
const Marketplace = artifacts.require('./Marketplace.sol')

require('chai')
    .use(require('chai-as-promised'))
    .should()

contract('Marketplace', (accounts) => {
    let token, market
    const nike = "NIKE"
    const nikePrice = web3.utils.toWei('0.01', 'Ether')

    before (async() => {
        token = await Tokenship.new()
        market = await Marketplace.new(token.address)
    })

    describe('deployment', async() => {
        it('deploys successfully', async() => {
            const address = market.address
            assert.notEqual(address, null)
            assert.notEqual(address, undefined)
            assert.notEqual(address, 0x0)
            assert.notEqual(address, '')
        })
    })

    describe('enlisting', async() => {
        it('enlists correctly', async() => {
            await token.mint(nike, 3)
            
            token.approve(market.address, 1)
            await market.enlist(1, nikePrice)

            sale = await market.getSale(1)
            assert.equal(sale[0], 1)
            assert.equal(sale[1], nikePrice)
            assert.equal(sale[2], accounts[0])
        })

        it('rejects enlisting enlisted tokens', async() => {
            await market.enlist(1, nikePrice).should.be.rejected
        })
    })
    
    describe('buying', async() => {
        it('allows another user to buy enlisted token', async() => {
            balance = await web3.eth.getBalance(accounts[0])
            await market.buy(0, {from: accounts[1], value: nikePrice})
            
            owner = await token.ownerOf(1)
            assert.equal(owner, accounts[1])
        })

        it ('should not retrieve sale info of the bought token', async() => {
            await market.getSale(1).should.be.rejected
        })

        it('rejects owners buying their own token', async() => {
            token.approve(market.address, 2)
            await market.enlist(2, nikePrice)
            
            await market.buy(1, {value: nikePrice}).should.be.rejected
        })
    })
})