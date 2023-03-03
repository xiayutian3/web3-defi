// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Context {
    function _msgSender() internal view returns(address) {
        return msg.sender;
    }
}