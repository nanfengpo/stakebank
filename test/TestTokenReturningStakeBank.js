const TokenReturningStakeBank = artifacts.require('TokenReturningStakeBank.sol');
const TokenMock = artifacts.require('./mocks/Token.sol');

contract('TokenReturningStakeBank', function (accounts) {

    let bank, token, returnToken, initialBalance;

    beforeEach(async () => {
        initialBalance = 10000;
        token = await TokenMock.new();
        returnToken = await TokenMock.new();
        bank = await TokenReturningStakeBank.new(token.address, returnToken.address, 2);

        await token.mint(accounts[0], initialBalance);
        await returnToken.mint(bank.address, initialBalance * 2);
    });

    it('should transfer tokens to bank when staked', async () => {
        await bank.stake(initialBalance);

        assert.equal(await token.balanceOf.call(accounts[0]), 0);
        assert.equal(await token.balanceOf.call(bank.address), initialBalance);
        assert.equal(await returnToken.balanceOf.call(accounts[0]), initialBalance * 2);
        assert.equal(await returnToken.balanceOf.call(bank.address), 0);
    });

    it('should allow user to unstake tokens', async () => {
        await bank.stake(initialBalance);
        assert.equal(await bank.totalStakedFor.call(accounts[0]), initialBalance);
        assert.equal(await returnToken.balanceOf.call(accounts[0]), initialBalance * 2);
        assert.equal(await returnToken.balanceOf.call(bank.address), 0);

        let amount = initialBalance / 2;
        await bank.unstake(amount);
        assert.equal(await bank.totalStakedFor.call(accounts[0]), amount);
        assert.equal(await returnToken.balanceOf.call(accounts[0]), (initialBalance * 2) - (amount / 2));
        assert.equal(await returnToken.balanceOf.call(bank.address), amount / 2);
    });
});
