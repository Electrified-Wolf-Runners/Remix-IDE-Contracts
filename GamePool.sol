// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./EWO_Nfts.sol";

contract GamePool is Ownable{
    IERC1155 nftcontract;
    IERC20 token;
    mapping (address => uint256) public obstacleRewards;
    // uint256[] public rewardsPerObstacleId = [5000, 5000, 5000];
    uint256 rewardsObstacleRate = 5000000000000000000;

    constructor(address obstacleNFTAddress, address tokenAddress){
         nftcontract = IERC1155(obstacleNFTAddress);
         token = IERC20(tokenAddress);
    }

    function updateObstacleRewards(address[] memory obstacleOwners) public onlyOwner(){
        require(obstacleOwners.length <= 3);
        for(uint i = 0; i < obstacleOwners.length; i++){
            address _owner = obstacleOwners[i];
            obstacleRewards[_owner] += 1;
        }
    }

    function claimObstacleRewards() public {
        require(obstacleRewards[msg.sender] > 0, "Cannot claim any rewards");
        uint256 amountToTransfer = obstacleRewards[msg.sender] * rewardsObstacleRate;
        obstacleRewards[msg.sender] = 0;
        (token).transfer(msg.sender, amountToTransfer);
    }
}
