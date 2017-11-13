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

    context('stake', async () => {

        let firstBlock;
        let secondBlock;

        beforeEach(async () => {
            firstBlock = web3.eth.blockNumber;
            secondBlock = firstBlock + 5;

            await bank.stake(initialBalance / 2);
            await advanceToBlock(secondBlock);
            await bank.stake(initialBalance / 2);
        });

        it('should return full staked value when calling totalStaked', async () => {
            assert.equal(await bank.totalStaked.call(accounts[0]), initialBalance);
        });
    });
});