//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IGame.sol";

enum Type {
    Boss,
    Character
}

abstract contract Player {
    IGame internal _game;

    address internal _owner;
    uint256 internal _healthPoints;
    uint256 internal _attackDamage;
    uint256 internal _experiencePoints;

    constructor(IGame _g, uint256 _hp) {
        _game = _g;

        _healthPoints = _hp;
        _attackDamage = 10;
        _experiencePoints = 0;
    }

    function isDefeated() external view returns (bool) {
        return _healthPoints <= 0;
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
