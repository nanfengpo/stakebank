pragma solidity 0.4.18;

import "./StakeBank.sol";

contract TokenReturningStakeBank is StakeBank {

    ERC20 public returnToken;

    uint256 public rate;

    /// @param _token Token that can be staked.
    /// @param _returnToken Token that is given to user once he stakes.
    /// @param _rate Rate of return tokens per token.
    function TokenReturningStakeBank(ERC20 _token, ERC20 _returnToken, uint256 _rate) StakeBank(_token) public {
        require(address(_returnToken) != 0x0);
        require(_token != _returnToken);
        require(_rate > 0);

        returnToken = _returnToken;
        rate = _rate;
    }

    /// @notice Stakes a certain amount of tokens.
    /// @param amount Amount of tokens to stake.
    function stake(uint256 amount) public {
        super.stake(amount);
        require(returnToken.transfer(msg.sender, amount * getRate())); // @todo safe math
    }

    /// @notice Unstakes a certain amount of tokens.
    /// @param amount Amount of tokens to unstake.
    function unstake(uint256 amount) public {
        super.unstake(amount);

        uint256 returnAmount = amount / getRate();
        require(returnAmount * getRate() == amount);

        require(returnToken.transferFrom(msg.sender, address(this), returnAmount)); // @todo safe math
    }

    /// @notice Returns conversion rate from token to returnToken. In function so it can be overridden.
    /// @return conversion rate.
    function getRate() public view returns (uint256) {
        return rate;
    }
}
