//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Player.sol";

contract Game is IGame {
    address private _admin;
    Player[] private _bosses;
    Player[] private _characters;
    mapping(address => int256) private _characterOwnerIdMap;

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

    function createBoss() external onlyAdmin {
        _bosses.push(new Player(this, Type.Boss));
    }

    function createCharacter() external {
        require(
            _characterOwnerIdMap[msg.sender] == 0,
            "Only one character per user"
        );

        _characters.push(new Player(this, Type.Character));
        _characterOwnerIdMap[msg.sender] = int256(_characters.length);
    }
}
