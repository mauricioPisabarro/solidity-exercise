//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Boss.sol";
import "./Character.sol";

/**
    Design decisions:
    - The game is a singleton, so it is deployed only once.
    - The every user interfaces only with the game, so that the other contracts are harder to hack.
    - Boss population was ambiguos, so I decided to make it so that there is only one at a time that's
    populated. In any case, it wouldn't be to hard to change this, it would add a couple of parameters
    and mappings here and there.
    - Boss' defeated rewards are higher
 */
contract Game is IGame {
    address private _admin;
    int256 private _currentBoss;
    uint256 private constant defeatedHp = 0;
    uint256 private constant defaultHp = 100;

    Boss[] private _bosses;
    Character[] private _characters;
    mapping(address => Character) private _userCharacterMap;
    mapping(address => bool) private _userHasCharacter;
    mapping(int256 => bool) private _defeatedBosses;

    event BossDefeated(
        uint256 indexed characterId,
        uint256 indexed bossId,
        uint256 reward
    );

    constructor() {
        _admin = msg.sender;
        _currentBoss = -1;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Only the admin can do this");
        _;
    }

    modifier onlyOneCharacterPerAddress() {
        require(
            _userHasCharacter[msg.sender] == false,
            "Only one character per user"
        );
        _;
    }

    modifier onlyIfNoCurrentBossOrDefeated() {
        require(
            _currentBoss == -1 || _defeatedBosses[_currentBoss] == true,
            "Current boss to be defeated"
        );
        _;
    }

    modifier onlyIfBossExists(uint256 _bossId) {
        require(
            _bossId < _bosses.length && _bossId >= 0,
            "Boss does not exist"
        );
        _;
    }

    modifier onlyIfBossIsPopulated() {
        require(
            _currentBoss >= 0 && uint256(_currentBoss) < _bosses.length,
            "Current boss not populated"
        );
        require(!_defeatedBosses[_currentBoss], "Current boss already defeated");
        _;
    }

    modifier needToOwnACharacter() {
        require(_userHasCharacter[msg.sender], "You need to own a character");
        _;
    }

    modifier onlyOwningExistingLivingCharacterWithXP() {
        require(_userHasCharacter[msg.sender], "You need to own a character");
        Character character = _userCharacterMap[msg.sender];
        require(character.isDead() == false, "You need a living character");
        require(
            character.getExperiencePoints() > 0,
            "You need a character with XP"
        );
        _;
    }

    modifier characterExists(uint256 _characterId) {
        require(
            _characterId < _characters.length && _characterId >= 0,
            "Character does not exist"
        );
        _;
    }

    function isAdmin(address _address) public view override returns (bool) {
        return _address == _admin;
    }

    function createBoss(
        uint256 _hps,
        uint256 _reward,
        uint256 _damage
    ) external onlyAdmin returns (uint256) {
        Boss boss = new Boss(this, _hps, msg.sender, _reward, _damage);
        _bosses.push(boss);
        uint256 playerId = _bosses.length - 1;
        boss.setId(playerId);

        return playerId;
    }

    function populateBoss(uint256 _bossIndex)
        external
        onlyAdmin
        onlyIfBossExists(_bossIndex)
        onlyIfNoCurrentBossOrDefeated
    {
        _currentBoss = int256(_bossIndex);
    }

    function createCharacter()
        external
        onlyOneCharacterPerAddress
        returns (uint256)
    {
        Character character = new Character(this, defaultHp, msg.sender);
        _characters.push(character);

        uint256 playerId = _characters.length - 1;
        character.setId(playerId);
        _userCharacterMap[msg.sender] = character;
        _userHasCharacter[msg.sender] = true;

        return playerId;
    }

    function attackBoss()
        external
        onlyIfBossIsPopulated
        needToOwnACharacter
        returns (bool)
    {
        Character character = _userCharacterMap[msg.sender];
        require(!character.isDead(), "Character is dead, can't attack");
        Boss boss = _bosses[uint256(_currentBoss)];

        bool isBossDefeated = boss.receiveAttack(character.getAttackDamage());
        if (isBossDefeated) {
            uint256 reward = boss.getDefeatedReward();
            character.receiveExperiencePoints(reward);
            _defeatedBosses[_currentBoss] = true;
            _currentBoss = -1;

            emit BossDefeated(
                character.getId(),
                boss.getId(),
                boss.getDefeatedReward()
            );

            return true;
        }

        bool isCharacterDefeated = character.receiveAttack(
            boss.getAttackDamage()
        );
        if (!isCharacterDefeated) {
            character.receiveExperiencePoints(boss.getOfferedReward());
        }

        return false;
    }

    function heal(uint256 _characterId)
        external
        onlyOwningExistingLivingCharacterWithXP
        characterExists(_characterId)
    {
        Character owned = _userCharacterMap[msg.sender];
        Character toHeal = _characters[_characterId];

        toHeal.heal(owned.getHealingPower());
    }
}
