//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IGame.sol";
import "./Player.sol";

contract Character is Player {
    uint256 private constant _maxHealthPoints = 100;
    uint256 private constant _xpLossOnDeath = 5;
    uint256 private _experiencePoints;
    uint256 private _healingPower;
    uint256 private _lastFireSpellTimestamp = 0;

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

    function getFireSpellDamage() external view returns (uint256) {
        return _attackDamage * 2;
    }

    function getLevel() external view returns (uint256) {
        // This makes it harder to level up for characters who got lucky
        // with attack damage.
        return (_experiencePoints / _attackDamage) + 1;
    }

    function performFireSpell() public returns (uint256) {
        require(this.getLevel() >= 3, "Need to be at least level 3");
        require(
            block.timestamp - _lastFireSpellTimestamp >= 24 hours,
            "1 fire spell per 24hrs"
        );

        _lastFireSpellTimestamp = block.timestamp;

        return this.getFireSpellDamage();
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

    function receiveHealingSpell(uint256 _hp) public onlyGame {
        if (_healthPoints + _hp > _maxHealthPoints) {
            _healthPoints = _maxHealthPoints;
        } else {
            _healthPoints += _hp;
        }
    }

    function heal() public view onlyGame returns (uint256) {
        require(this.getLevel() == 2, "Need to be at least level 2");

        return _healingPower;
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
