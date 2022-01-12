// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

contract DapptoolsDemo {

    function play(uint8 password) public pure returns(bool){
        if(password == 55){
            return false;
        }
        return true;
    }
}
