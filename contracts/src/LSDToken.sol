// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
contract LSDToken is ERC20, Ownable {
    address public authorizedMinter;
    error NotMinter();
    constructor(string memory n, string memory s, address owner_) ERC20(n, s) Ownable(owner_) {}
    function setMinter(address m) external onlyOwner { authorizedMinter = m; }
    function mint(address to, uint256 a) external { if (msg.sender != authorizedMinter) revert NotMinter(); _mint(to,a);} 
    function burnFrom(address from, uint256 a) external { if (msg.sender != authorizedMinter) revert NotMinter(); _burn(from,a);} 
}
\n// k 4
\n// k 10
