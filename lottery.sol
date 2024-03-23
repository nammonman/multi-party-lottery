// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./commitreveal.sol";

contract lottery is CommitReveal {
    uint private stage = 1;
    uint private numPlayer = 2;
    uint private currPlayer = 1;
    uint private numReveal = 0;
    uint private startTime = 0;
    uint private T1 = 0;
    uint private T2 = 0;
    uint private T3 = 0;
    mapping (address => uint) private userTransaction;
    mapping (uint => address) private userNum;
    address[] public validUser;
    constructor(uint _N, uint _T1, uint _T2, uint _T3) {
        require(_N >= 2);
        numPlayer = _N;
        T1 = _T1;
        T2 = _T2;
        T3 = _T3;
    }

    function reset() private  {
        stage = 1;
        currPlayer = 1;
        numReveal = 0;
        startTime = 0;
        delete validUser;
    }

    function addUser(uint transaction, uint salt) public payable {
        require(msg.value == 1000);
        require(transaction >= 0 && transaction <= 999);
        require(currPlayer < numPlayer);
        if (startTime == 0) {
            startTime = block.timestamp;
        }
        if (block.timestamp - startTime > T1) {
            advanceStage(2);
        }
        require(stage == 1);
        commit(getSaltedHash(bytes32(transaction), bytes32(transaction + salt)));
        userTransaction[msg.sender] = 1000;
        userNum[currPlayer] = msg.sender;
        currPlayer += 1;
        if (currPlayer == numPlayer) {
            advanceStage(2);
        }
    }

    function advanceStage(uint _stage) public {
        if (_stage == 2) {
            require(stage == 1);
            require(block.timestamp - startTime > T1);
            stage = 2;
            startTime = 0;
        }
        if (_stage == 3) {
            require(stage == 2);
            require(block.timestamp - startTime > T2);
            stage = 3;
            startTime = 0;
        }
        if (_stage == 4) {
            require(stage == 3);
            require(block.timestamp - startTime > T3);
            stage = 4;
            startTime = 0;
        }
    }


    function revealUser(uint transaction, uint salt) public {
        require(userTransaction[msg.sender] == 0);
        if (startTime == 0) {
            startTime = block.timestamp;
        }
        if (block.timestamp - startTime > T2) {
            advanceStage(3);
        }
        require(stage == 2);
        revealAnswer(bytes32(transaction), bytes32(transaction + salt));
        userTransaction[msg.sender] = transaction;
        numReveal++;
        if (numReveal == numPlayer) {
            advanceStage(3);
        }
    }

    function findWinner() private {
        if (startTime == 0) {
            startTime = block.timestamp;
        }
        if (block.timestamp - startTime > T3) {
            advanceStage(4);
        }
        require(stage == 3);
        uint numValid = 0;
        uint winner = 1000;
        address payable owner = payable(0x0571786E18ADb3b155E40FF9AcaED79016f0E7b7);
        for (uint i=1; i < numPlayer; i++) 
        {
            if (userTransaction[userNum[i]] > 999) { // bad user
                continue; 
            }
            if (winner == 1000) { // first user
                winner = userTransaction[userNum[i]];
                numValid++;
                validUser.push(userNum[i]);
                continue;
            }
            else { // rest of the users
                winner = winner ^ userTransaction[userNum[i]];
                numValid++;
                validUser.push(userNum[i]);
            }
        }
        if (numValid > 0) {
            winner = winner % numValid;
            address payable account = payable(validUser[winner]);
            account.transfer(numPlayer*980);
            owner.transfer(numPlayer*20);
        }
        else {
            owner.transfer(numPlayer*1000);
        }
    }

    function refund() public payable {
        require(stage == 4);
        require(userTransaction[msg.sender] >= 0 && userTransaction[msg.sender] < 1000);
        address payable account = payable(msg.sender);
        account.transfer(1000);
        userTransaction[msg.sender] = 1000;
    }
}