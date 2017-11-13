const StakeBank = artifacts.require('StakeBank.sol');
const TokenMock = artifacts.require('./mocks/Token.sol');

function advanceBlock() {
    return new Promise((resolve, reject) => {
        web3.currentProvider.sendAsync({
            jsonrpc: '2.0',
            method: 'evm_mine',
            id: Date.now(),
        }, (err, res) => {
            return err ? reject(err) : resolve(res)
        })
    })
}

async function advanceToBlock(number) {
    if (web3.eth.blockNumber > number) {
        throw Error(`block number ${number} is in the past (current is ${web3.eth.blockNumber})`)
    }

    while (web3.eth.blockNumber < number) {
        await advanceBlock()
    }
}

contract('StakeBank', function (accounts) {

    let bank, token, initialBalance;

    beforeEach(async () => {
        initialBalance = 10000;
        token = await TokenMock.new();
        bank = await StakeBank.new(token.address);

        await token.mint(accounts[0], initialBalance);
    });

    it('should transfer tokens to bank when staked', async () => {
        await bank.stake(initialBalance);

        assert.equal(await token.balanceOf.call(accounts[0]), 0);
        assert.equal(await token.balanceOf.call(bank.address), initialBalance);
    });

    it('should allow user to unstake tokens', async () => {
        await bank.stake(initialBalance);
        assert.equal(await bank.totalStaked.call(accounts[0]), initialBalance);
        await bank.unstake(initialBalance / 2);
        assert.equal(await bank.totalStaked.call(accounts[0]), initialBalance / 2);
    });

    context('staking constants', async () => {

        let firstBlock;
        let secondBlock;

        beforeEach(async () => {
            firstBlock = web3.eth.blockNumber;
            secondBlock = firstBlock + 5;

            let result = await bank.stake(initialBalance / 2);
            firstBlock = result['receipt']['blockNumber'];

            await advanceToBlock(secondBlock);

            result = await bank.stake(initialBalance / 2);
            secondBlock = result['receipt']['blockNumber'];
        });

        it('should return full staked value when calling totalStaked', async () => {
            assert.equal(await bank.totalStaked.call(accounts[0]), initialBalance);
        });

        it('should return correct amount staked at block', async () => {
            assert.equal(await bank.totalStakedAt.call(accounts[0], firstBlock), initialBalance / 2);
        });

        it('should return correct block when calling lastStaked', async () => {
            assert.equal(await bank.lastStaked.call(accounts[0]), secondBlock);
        });
    });
});