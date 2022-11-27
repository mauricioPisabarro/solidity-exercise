//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Player.sol";

contract Game is IGame {
    address private _admin;
    Player[] private _bosses;
    mapping(address => Player) private _characters;

    constructor() {
        _admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Only the admin can do this");
        _;
    }

    function isAdmin(address _address) public view returns (bool) {
        return _address == _admin;
    }

    function createBoss() public override onlyAdmin {
        _bosses.push(new Player(this, Type.Boss));
    }
}
