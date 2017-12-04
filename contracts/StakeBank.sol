pragma solidity 0.4.18;

import "./Lifecycle/Lockable.sol";
import "./Ownership/Ownable.sol";
import "./ERC20.sol";
import "./StakeBankInterface.sol";
import "./SafeMath.sol";

contract StakeBank is StakeBankInterface, Ownable, Lockable {

    using SafeMath for uint256;

    struct Checkpoint {
        uint256 at;
        uint256 amount;
    }

    ERC20 public token;

    Checkpoint[] public stakeHistory;

    mapping (address => Checkpoint[]) public stakesFor;

    /// @param _token Token that can be staked.
    function StakeBank(ERC20 _token) public {
        require(address(_token) != 0x0);
        token = _token;
    }

    /// @notice Stakes a certain amount of tokens.
    /// @param amount Amount of tokens to stake.
    function stake(uint256 amount) public onlyWhenUnlocked {
        updateCheckpointAtNow(stakesFor[msg.sender], amount, false);
        updateCheckpointAtNow(stakeHistory, amount, false);

        require(token.transferFrom(msg.sender, address(this), amount));
    }

    /// @notice Unstakes a certain amount of tokens.
    /// @param amount Amount of tokens to unstake.
    function unstake(uint256 amount) public {
        require(totalStakedFor(msg.sender) >= amount);

        updateCheckpointAtNow(stakesFor[msg.sender], amount, true);
        updateCheckpointAtNow(stakeHistory, amount, true);

        require(token.transfer(msg.sender, amount));
    }

    // @todo code can be optimized by adding into stakedAt function
    /// @notice Returns total tokens staked for address.
    /// @param addr Address to check.
    /// @return amount of tokens staked.
    function totalStakedFor(address addr) public view returns (uint256) {
        Checkpoint[] storage stakes = stakesFor[addr];

        if (stakes.length == 0) {
            return 0;
        }

        return stakes[stakes.length-1].amount;
    }

    /// @notice Returns last block address staked at.
    /// @param addr Address to check.
    /// @return block number of last stake.
    function lastStakedFor(address addr) public view returns (uint256) {
        Checkpoint[] storage stakes = stakesFor[addr];

        if (stakes.length == 0) {
            return 0;
        }

        return stakes[stakes.length-1].at;
    }

    /// @notice Returns total amount of tokens staked at block for address.
    /// @param addr Address to check.
    /// @param blockNumber Block number to check.
    /// @return amount of tokens staked.
    function totalStakedForAt(address addr, uint256 blockNumber) public view returns (uint256) {
        return stakedAt(stakesFor[addr], blockNumber);
    }

    /// @notice Returns the total tokens staked at block.
    /// @param blockNumber Block number to check.
    /// @return amount of tokens staked.
    function totalStakedAt(uint256 blockNumber) public view returns (uint256) {
        return stakedAt(stakeHistory, blockNumber);
    }

    function updateCheckpointAtNow(Checkpoint[] storage history, uint256 amount, bool isUnstake) internal {

        uint256 length = history.length;
        if (length == 0) {
            history.push(Checkpoint({at: block.number, amount: amount}));
            return;
        }

        if (history[length-1].at < block.number) {
            history.push(Checkpoint({at: block.number, amount: history[length-1].amount}));
        }

        Checkpoint storage checkpoint = history[length];

        if (isUnstake) {
            checkpoint.amount = checkpoint.amount.sub(amount);
        } else {
            checkpoint.amount = checkpoint.amount.add(amount);
        }
    }

    function stakedAt(Checkpoint[] storage history, uint256 blockNumber) internal view returns (uint256) {
        uint256 length = history.length;

        if (length == 0 || blockNumber < history[0].at) {
            return 0;
        }

        if (blockNumber >= history[length-1].at) {
            return history[length-1].amount;
        }

        for (uint i = (length - 1); i >= 0; i--) {
            if (history[i].at <= blockNumber) {
                return history[i].amount;
            }
        }

        return 0;
    }
}
