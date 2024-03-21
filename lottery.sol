// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./commitreveal.sol";

contract lottery is CommitReveal {
    uint stage = 1;
    uint numPlayer = 0;
    uint currPlayer = 1;
    uint numReveal = 0;
    uint startTime = 0;
    uint T1 = 0;
    uint T2 = 0;
    uint T3 = 0;
    mapping (address => uint) userTransaction;

    constructor(uint _N, uint _T1, uint _T2, uint _T3) {
        numPlayer = _N;
        T1 = _T1;
        T2 = _T2;
        T3 = _T3;
    }

    function reset() private  {
        stage = 1;
        numPlayer = 0;
        startTime = 0;
        T1 = 0;
    }

    function addUser(uint transaction, uint salt) public payable {
        require(msg.value == 1000);
        require(transaction > 0);
        require(currPlayer < numPlayer);
        if (startTime == 0) {
            startTime = block.timestamp;
        }
        if (block.timestamp - startTime < T1) {
            stage = 2;
            startTime = 0;
        }
        require(stage == 1);
        commit(getSaltedHash(bytes32(transaction), bytes32(transaction + salt)));
        userTransaction[msg.sender] = 0;
        currPlayer += 1;
        if (currPlayer == numPlayer) {
            stage = 2;
            startTime = 0;
        }
    }

    function revealUser(uint transaction, uint salt) public {
        require(userTransaction[msg.sender] == 0);
        if (startTime == 0) {
            startTime = block.timestamp;
        }
        if (block.timestamp - startTime < T2) {
            stage = 3;
            startTime = 0;
        }
        require(stage == 2);
        revealAnswer(bytes32(transaction), bytes32(transaction + salt));
        userTransaction[msg.sender] = transaction;
        numReveal++;
        if (numReveal == numPlayer) {
            stage = 3;
            startTime = 0;
        }
    }

}