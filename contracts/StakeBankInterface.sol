pragma solidity 0.4.18;

interface StakeBankInterface {

    function stake(uint256 amount) public;
    function unstake(uint256 amount) public;
    function totalStakedFor(address addr) public view returns (uint256);
    function lastStakedFor(address addr) public view returns (uint256);
    function totalStakedForAt(address addr, uint256 blockNumber) public view returns (uint256);
    function totalStakedAt(uint256 blockNumber) public view returns (uint256);
}
