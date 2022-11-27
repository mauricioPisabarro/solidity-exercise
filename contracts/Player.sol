//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IGame.sol";

enum Type {
    Boss,
    Character
}

contract Player {
    IGame private _game;
    Type private _type;
    address private _owner;
    uint256 private _healthPoints;
    uint256 private _attackDamage;
    uint256 private _experiencePoints;

    constructor(IGame _g, Type _t) {
        _game = _g;
        _type = _t;

        _healthPoints = 100;
        _attackDamage = 10;
        _experiencePoints = 0;
    }

    function getHealthPoints() external view returns (uint256) {
        return _healthPoints;
    }

    function getAttackDamage() external view returns (uint256) {
        return _attackDamage;
    }

    function getExperiencePoints() external view returns (uint256) {
        return _experiencePoints;
    }
}
