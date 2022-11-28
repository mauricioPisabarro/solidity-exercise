//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IGame.sol";

enum Type {
    Boss,
    Character
}

abstract contract Player {
    IGame internal _game;

    uint256 internal _id;
    address internal _owner;
    uint256 internal _healthPoints;
    uint256 internal _attackDamage;

    constructor(IGame _g, uint256 _hp, address _ownr) {
        _game = _g;
        _owner = _ownr;

        _healthPoints = _hp;
    }

    modifier onlyGame() {
        require(msg.sender == address(_game), "Only the game can do this");
        _;
    }

    function getId() public view returns (uint256) {
        return _id;
    }

    function setId(uint256 _i) public onlyGame {
        _id = _i;
    }

    function receiveAttack(uint256 damage) external onlyGame returns (bool) {
        if (damage >= _healthPoints) {
            _healthPoints = 0;
            return true;
        }

        _healthPoints -= damage;
        return false;
    } 

    function isDead() external view returns (bool) {
        return _healthPoints <= 0;
    }

    function getHealthPoints() external view returns (uint256) {
        return _healthPoints;
    }

    function getAttackDamage() external view returns (uint256) {
        return _attackDamage;
    }
}
