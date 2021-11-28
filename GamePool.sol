// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./EWO_Nfts.sol";

contract GamePool is Ownable{
    IERC1155 nftcontract;
    IERC20 token;
    mapping (address => uint256) public obstacleNFTRewards;
    mapping (address => uint256) public landNFTRewards;
    mapping (address => bool) public playerFeesPaid;
    // uint256[] public rewardsPerObstacleId = [5000, 5000, 5000];

    uint256 rewardsObstacleRate = 25000000000000000000;
    uint256 entryFees = 100000000000000000000;
    uint256 rewardsLandRate = 15000000000000000000;
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

    function updateRewards(address[] memory _nftOwners) public {
        require(_nftOwners.length <= 4);
        //Can add ownership check of nft in future to make contract more secure
        require(playerFeesPaid[msg.sender] == true);
        playerFeesPaid[msg.sender] = false;
        for(uint i = 0; i < _nftOwners.length - 1; i++){
            address _owner = _nftOwners[i];
            obstacleNFTRewards[_owner] += 1;
        }
        address _landOwner = _nftOwners[3];
        landNFTRewards[_landOwner] += 1; 
    }

    function claimObstacleNFTRewards() public {
        require(obstacleNFTRewards[msg.sender] > 0, "Cannot claim any Obstacle rewards");
        uint256 amountToTransfer = obstacleNFTRewards[msg.sender] * rewardsObstacleRate;
        obstacleNFTRewards[msg.sender] = 0;
        (token).transfer(msg.sender, amountToTransfer);
    }

    function claimLandNFTRewards() public {
        require(landNFTRewards[msg.sender] > 0, "Cannot claim any Land rewards");
        uint256 amountToTransfer = landNFTRewards[msg.sender] * rewardsLandRate;
        landNFTRewards[msg.sender] = 0;
        (token).transfer(msg.sender, amountToTransfer);
    }
}
