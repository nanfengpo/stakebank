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

    function stake(uint256 amount) public onlyWhenUnlocked {
        addStake(msg.sender, block.number, totalStaked(msg.sender) + amount);
        require(token.transferFrom(msg.sender, address(this), amount));
    }

    function unstake(uint256 amount) public {
        uint256 total = totalStaked(msg.sender);
        require(totalStaked(msg.sender) >= amount);
        addStake(msg.sender, block.number, total - amount);
        require(token.transfer(msg.sender, amount));
    }

    function totalStaked(address addr) public view returns (uint256) {
        Stake[] storage stakes = checkpoints[addr];

        if (stakes.length == 0) {
            return 0;
        }

        return stakes[stakes.length-1].value;
    }

    function lastStaked(address addr) public view returns (uint256) {
        Stake[] storage stakes = checkpoints[addr];

        if (stakes.length == 0) {
            return 0;
        }

        return stakes[stakes.length-1].blockNumber;
    }

    function totalStakedAt(address addr, uint256 blockNumber) public view returns (uint256) {
        if (blockNumber >= lastStaked(addr)) {
            return totalStaked(addr);
        }

        Stake[] storage stakes = checkpoints[addr];
        for (uint i = (stakes.length - 1); i >= 0; i--) {
            if (stakes[i].blockNumber <= blockNumber) {
                return stakes[i].value;
            }
        }

        return 0;
    }

    function addStake(address addr, uint256 blockNumber, uint256 amount) internal {
        checkpoints[addr].push(Stake({blockNumber: blockNumber, value: amount}));
    }
}
