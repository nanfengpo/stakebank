pragma solidity 0.4.18;

contract Token {

    mapping (address => uint) balances;
    
    function balanceOf(address owner) returns (uint256) {
        return balances[owner];
    }

    function transfer(address to, uint value) returns (bool) {
        balances[msg.sender] = balances[msg.sender] - value;
        balances[to] = balances[to] + value;
        return true;
    }

    function transferFrom(address _from, address to, uint value) returns (bool) {
        balances[_from] = balances[_from] - value;
        balances[to] = balances[to] + value;
        return true;
    }

    function mint(address to, uint _amount) public {
        balances[to] = balances[to] + _amount;
    }
}