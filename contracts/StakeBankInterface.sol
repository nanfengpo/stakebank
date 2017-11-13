pragma solidity 0.4.18;

interface StakeBankInterface {

    function stake(uint256 amount) public;
    function unstake(uint256 amount) public;
    function totalStaked(address addr) public view returns (uint256);
    function lastStaked(address addr) public view returns (uint256);
    function totalStakedAt(address addr, uint256 blockNumber) public view returns (uint256);

}
