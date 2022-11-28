//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IGame.sol";
import "./Player.sol";

contract Boss is Player {
    uint256 private _offeredReward;

    constructor(
        IGame _g,
        uint256 _hp,
        address _ownr,
        uint256 _offeredRwrd,
        uint256 _atkDmg
    ) Player(_g, _hp, _ownr) {
        _offeredReward = _offeredRwrd;
        _attackDamage = _atkDmg;
    }

    modifier onlyAdmin() {
        require(_game.isAdmin(msg.sender), "Only the admin can do this");
        _;
    }

    function getOfferedReward() public view returns (uint256) {
        return _offeredReward;
    }
}
