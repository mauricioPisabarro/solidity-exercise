//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces/IGame.sol";
import "./Player.sol";

contract Character is Player {
  constructor(IGame _g, uint256 _hp) Player(_g, _hp) {}
}
