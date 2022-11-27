//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IGame.sol";
import "./Player.sol";

contract Boss is Player {
  uint256 private _offeredReward;

  constructor(IGame _g, uint256 _hp) Player(_g, _hp) {}

  modifier onlyAdmin() {
    require(_game.isAdmin(msg.sender), "Only the admin can do this");
    _;
  }

  function getOfferedRewards() external view returns (uint256) {
    return _offeredReward;
  }

  function setOfferedRewards(uint256 _reward) external {
    _offeredReward = _reward;
  }
}