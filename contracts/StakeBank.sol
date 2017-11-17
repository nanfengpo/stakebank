pragma solidity 0.4.18;

import "./Lifecycle/Lockable.sol";
import "./Ownership/Ownable.sol";
import "./ERC20.sol";
import "./StakeBankInterface.sol";

contract StakeBank is StakeBankInterface, Ownable, Lockable {

    struct Stake {
        uint256 blockNumber;
        uint256 amount;
    }

    ERC20 public token;

    mapping (address => Stake[]) public stakesFor;

    /// @param _token Token that can be staked.
    function StakeBank(ERC20 _token) public {
        require(address(_token) != 0x0);
        token = _token;
    }

    /// @notice Stakes a certain amount of tokens.
    /// @param amount Amount of tokens to stake.
    function stake(uint256 amount) public onlyWhenUnlocked {
        addStake(msg.sender, block.number, totalStaked(msg.sender) + amount);
        require(token.transferFrom(msg.sender, address(this), amount));
    }

    /// @notice Unstakes a certain amount of tokens.
    /// @param amount Amount of tokens to unstake.
    function unstake(uint256 amount) public {
        uint256 total = totalStaked(msg.sender);
        require(totalStaked(msg.sender) >= amount);
        addStake(msg.sender, block.number, total - amount);
        require(token.transfer(msg.sender, amount));
    }

    /// @notice Returns total tokens staked for address.
    /// @param addr Address to check.
    /// @return amount of tokens staked.
    function totalStaked(address addr) public view returns (uint256) {
        Stake[] storage stakes = stakesFor[addr];

        if (stakes.length == 0) {
            return 0;
        }

        return stakes[stakes.length-1].amount;
    }

    /// @notice Returns last block address staked at.
    /// @param addr Address to check.
    /// @return block number of last stake.
    function lastStaked(address addr) public view returns (uint256) {
        Stake[] storage stakes = stakesFor[addr];

        if (stakes.length == 0) {
            return 0;
        }

        return stakes[stakes.length-1].blockNumber;
    }

    /// @notice Returns total amount of tokens staked at block for address.
    /// @param addr Address to check.
    /// @param blockNumber Block number to check.
    /// @return amount of tokens staked.
    function totalStakedAt(address addr, uint256 blockNumber) public view returns (uint256) {
        if (blockNumber >= lastStaked(addr)) {
            return totalStaked(addr);
        }

        Stake[] storage stakes = stakesFor[addr];
        for (uint i = (stakes.length - 1); i >= 0; i--) {
            if (stakes[i].blockNumber <= blockNumber) {
                return stakes[i].amount;
            }
        }

        return 0;
    }

    function addStake(address addr, uint256 blockNumber, uint256 amount) internal {
        stakesFor[addr].push(Stake({blockNumber: blockNumber, amount: amount}));
    }
}
