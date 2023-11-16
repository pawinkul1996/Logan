// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {LSDToken} from "./LSDToken.sol";
contract StakeManager {
    event Deposited(address indexed a, uint256 eth, uint256 shares);
    event Withdrawn(address indexed a, uint256 shares, uint256 eth);
    LSDToken public immutable lsd; uint256 public totalPooledEther; uint256 public totalShares; mapping(address=>uint256) public sharesOf;
    constructor(){ lsd = new LSDToken("Logan LSD","stLSD", address(this)); lsd.setMinter(address(this)); }
    function previewDeposit(uint256 amt) public view returns(uint256){ if(amt==0) return 0; if(totalShares==0||totalPooledEther==0) return amt; return amt*totalShares/totalPooledEther; }
    function previewWithdraw(uint256 s) public view returns(uint256){ if(s==0||totalShares==0) return 0; return s*totalPooledEther/totalShares; }
    function deposit() external payable returns(uint256 ms){ ms=_deposit(msg.sender,msg.value);} 
    receive() external payable { _deposit(msg.sender,msg.value); }
    function _deposit(address a,uint256 amt) internal returns(uint256 ms){ require(amt>0,"ZERO_VALUE"); ms=previewDeposit(amt); totalPooledEther+=amt; totalShares+=ms; sharesOf[a]+=ms; lsd.mint(a,ms); emit Deposited(a,amt,ms);} 
    function withdraw(uint256 s) external returns(uint256 eth){ require(s>0,"ZERO_VALUE"); require(sharesOf[msg.sender]>=s,"INSUFFICIENT_SHARES"); eth=previewWithdraw(s); require(eth<=address(this).balance,"INSUFFICIENT_LIQUIDITY"); sharesOf[msg.sender]-=s; totalShares-=s; totalPooledEther-=eth; lsd.burnFrom(msg.sender,s); (bool ok,)=msg.sender.call{value:eth}(""); require(ok,"TRANSFER_FAIL"); emit Withdrawn(msg.sender,s,eth);} 
}
\n// m 5
\n// m 11
\n// m 17
\n// m 23
\n// m 29
\n// m 35
\n// m 41
\n// m 47
\n// m 53
\n// m 59
\n// m 65
\n// m 71
