// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./EWO_Nfts.sol";

contract GamePool is Ownable{
    IERC1155 nftcontract;
    IERC20 token;
    mapping (address => uint256) public obstacleRewards;
    mapping (address => bool) public playerFeesPaid;
    // uint256[] public rewardsPerObstacleId = [5000, 5000, 5000];

    uint256 rewardsObstacleRate = 25000000000000000000;
    uint256 entryFees = 100000000000000000000;
    // address payable feesRecipient;

    constructor(address tokenAddress){
        //  feesRecipient = _feesRecipient;
         token = IERC20(tokenAddress);
    }

    // function payFees() public payable{
    //     require(msg.value >= _amount);
    //     playerFeesPaid[msg.sender] = true;
    //     (bool sent, ) =  feesRecipient.call{value: _amount}("") ;
    //     require(sent, "Fees was not paid successfully");
    // }

    function payFees() public {
        require((token).transferFrom(msg.sender, address(this), entryFees));
        playerFeesPaid[msg.sender] = true;
    }

    function getContractBalance() public view returns(uint256){
        return address(this).balance;
    }

    function updateObstacleRewards(address[] memory obstacleOwners) public {
        require(obstacleOwners.length <= 3);
        require(playerFeesPaid[msg.sender] == true);
        playerFeesPaid[msg.sender] = false;
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
