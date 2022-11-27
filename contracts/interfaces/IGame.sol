//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IGame {
  function isAdmin(address _address) external view returns (bool);
}
