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
\n// k 16
\n// k 22
\n// k 28
\n// k 34
\n// k 40
\n// k 46
\n// k 52
\n// k 58
\n// k 64
\n// k 70
\n// k 76
\n// k 82
\n// k 88
\n// k 94
\n// k 100
\n// k 106
\n// k 112
\n// k 118
