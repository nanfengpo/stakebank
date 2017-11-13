pragma solidity 0.4.18;

interface StakeBankInterface {

    function stake(uint256 amount) external;
    function unstake(uint256 amount) external;
    function totalStaked(address addr) external view returns (uint256);
    function lastStaked(address addr) external view returns (uint256);
    function totalStakedAt(address addr, uint256 blockNumber) external view returns (uint256);

}
