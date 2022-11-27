//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Player.sol";

contract Game is IGame {
    uint256 private constant defeatedHp = 0;
    uint256 private constant defaultHp = 100;
    address private _admin;
    Player private _boss;
    Player[] private _characters;
    Type private _turn;
    mapping(address => int256) private _characterOwnerIdMap;

    constructor() {
        _admin = msg.sender;
        _boss = new Player(this, Type.Boss, defeatedHp);
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Only the admin can do this");
        _;
    }

    modifier onlyIfBossIsDefeated() {
        require(_boss.isDefeated(), "The current boss must be defeated");
        _;
    }

    modifier onlyOneCharacterPerAddress() {
        require(
            _characterOwnerIdMap[msg.sender] == 0,
            "Only one character per user"
        );
        _;
    }

    function isAdmin(address _address) public view returns (bool) {
        return _address == _admin;
    }

    function createBoss() external onlyAdmin onlyIfBossIsDefeated {
        _boss = new Player(this, Type.Boss, defaultHp);
    }

    function createCharacter() external onlyOneCharacterPerAddress {
        _characters.push(new Player(this, Type.Character, defaultHp));
        _characterOwnerIdMap[msg.sender] = int256(_characters.length);
    }
}
