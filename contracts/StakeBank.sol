pragma solidity 0.4.18;

import "./Lifecycle/Lockable.sol";
import "./Ownership/Ownable.sol";
import "./ERC20.sol";
import "./StakeBankInterface.sol";

contract StakeBank is StakeBankInterface, Ownable, Lockable {

    struct Stake {
        uint256 blockNumber;
        uint256 value;
    }

    ERC20 public token;

    mapping (address => Stake[]) checkpoints;

    function StakeBank(ERC20 _token) {
        token = _token;
    }

    function stake(uint256 amount) external onlyWhenUnlocked {
        addStake(msg.sender, block.number, amount);
        require(token.transferFrom(msg.sender, address(this), amount));
    }

    function unstake(uint256 amount) external {
        require(totalStaked(msg.sender) >= amount);
        addStake(msg.sender, block.number, amount);
        require(token.transfer(msg.sender, amount));
    }

    function totalStaked(address addr) external view returns (uint256) {
        Stake[] stakes = checkpoints[addr];
        return stakes[stakes.length-1].value;
    }

    function lastStaked(address addr) external view returns (uint256) {
        Stake[] stakes = checkpoints[addr];
        return stakes[stakes.length-1].blockNumber;
    }

    function totalStakedAt(address addr, uint256 blockNumber) external view returns (uint256) {
        if (blockNumber >= lastStaked(addr)) {
            return totalStaked(addr);
        }

        Stake[] stakes = checkpoints[addr];
        for (uint i = stakes.length - 1; i >= 0; i--) {
            if (stakes[i].blockNumber > blockNumber) {
                continue;
            }

            return stakes[i].value;
        }

        return 0;
    }

    function addStake(address addr, uint256 blockNumber, uint256 amount) internal {
        checkpoints.push(Stake({blockNumber: blockNumber, value: amount}));
    }
}
