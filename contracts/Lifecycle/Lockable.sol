pragma solidity 0.4.18;

contract Lockable {

    bool public locked;

    modifier onlyWhenUnlocked() {
        require(!locked);
        _;
    }

    function lock() external {
        locked = true;
    }

    function unlock() external {
        locked = false;
    }
}
