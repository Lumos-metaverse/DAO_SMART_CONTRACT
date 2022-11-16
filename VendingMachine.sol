// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract VendingMachine {


    address public owner;
    mapping (address => uint) public cupcakeBalances;


    constructor() {
        owner = msg.sender;
        cupcakeBalances[address(this)] = 100;
    }


    function purchase(uint amount) public payable {
        require(msg.value >= amount * 1 ether, "You must pay at least 1 ETH per cupcake");
        require(cupcakeBalances[address(this)] >= amount, "Not enough cupcakes in stock to complete this purchase");
        cupcakeBalances[address(this)] -= amount;
        cupcakeBalances[msg.sender] += amount;
    }
}