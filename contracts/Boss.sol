//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IGame.sol";
import "./Player.sol";

contract Boss is Player {
  uint256 private _offeredReward;

  constructor(IGame _g, uint256 _hp) Player(_g, _hp) {}

  function getOfferedRewards() external view returns (uint256) {
    return _offeredReward;
  }
}