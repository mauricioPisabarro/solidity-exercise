//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Boss.sol";
import "./Character.sol";

contract Game is IGame {
    address private _admin;
    int256 private _currentBoss;
    uint256 private constant defeatedHp = 0;
    uint256 private constant defaultHp = 100;

    Boss[] private _bosses;
    Character[] private _characters;
    Type private _turn;
    mapping(address => bool) private _userHasCharacter;
    mapping(int256 => bool) private _defeatedBosses;

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
        require(_bosses.length < _bossId, "Boss does not exist");
        _;
    }

    function isAdmin(address _address) public view override returns (bool) {
        return _address == _admin;
    }

    function createBoss() external onlyAdmin returns (uint256) {
        _bosses.push(new Boss(this, defaultHp));

        return _bosses.length - 1;
    }

    function populateBoss(uint256 _bossIndex)
        external
        onlyAdmin
        onlyIfBossExists(_bossIndex)
        onlyIfNoCurrentBossOrDefeated
    {
        _currentBoss = int256(_bossIndex);
        _turn = Type.Boss;
    }

    function createCharacter()
        external
        onlyOneCharacterPerAddress
    {
        _characters.push(new Character(this, defaultHp));
        _userHasCharacter[msg.sender] = true;
    }
}
