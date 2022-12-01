//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IGame.sol";
import "./Player.sol";

contract Character is Player {
    uint256 private constant _maxHealthPoints = 100;
    uint256 private constant _xpLossOnDeath = 5;
    uint256 private _experiencePoints;
    uint256 private _healingPower;

    constructor(
        IGame _g,
        uint256 _hp,
        address _ownr
    ) Player(_g, _hp, _ownr) {
        // Attack damage is a number between 1 and 100
        _attackDamage = (random(0) % _maxHealthPoints) + 1;
        // Healing power is a number between 1 and 10
        _healingPower = (random(3) % _maxHealthPoints) + 1;
    }

    function getExperiencePoints() external view returns (uint256) {
        return _experiencePoints;
    }

    function getHealingPower() external view returns (uint256) {
        return _healingPower;
    }

    function receiveAttack(uint256 damage)
        public
        override(Player)
        onlyGame
        returns (bool)
    {
        bool isDead = super.receiveAttack(damage);
        if (isDead) {
            _experiencePoints = _experiencePoints < _xpLossOnDeath
                ? 0
                : _experiencePoints - _xpLossOnDeath;
        }

        return isDead;
    }

    function receiveExperiencePoints(uint256 _points) public onlyGame {
        _experiencePoints += _points;
    }

    function heal(uint256 _hp) public onlyGame {
        if (_healthPoints + _hp > _maxHealthPoints) {
            _healthPoints = _maxHealthPoints;
        } else {
            _healthPoints += _hp;
        }
    }

    function random(uint256 _randSeed) private view returns (uint256) {
        // THIS COULD BE EXPLOITED.
        // The best way would be to take the random aspect outside of the blockhain,
        // probably calling a propietary API.
        // https://stackoverflow.com/questions/48848948/how-to-generate-a-random-number-in-solidity
        return
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, _randSeed)
                )
            );
    }
}
