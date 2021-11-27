// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC1155/presets/ERC1155PresetMinterPauser.sol)

pragma solidity ^0.8.0;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/finance/PaymentSplitter.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "./EWO_Nfts.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GamePool is ERC1155Receiver, Ownable{
    IERC1155 nftcontract;
    IERC20 token;
    
    // Mapping from obstacle_id to Owner address to token_id 
    mapping(uint8 => mapping (address => uint256)) public _tokenid;
    
    // Mapping from obstacle_id to obstacles sold 
    mapping (uint8 => uint256) public _sold;
    
    // Mapping from obstacle id to token ID to owner address
    mapping(uint8 => mapping (uint256 => address)) public _owners;
    
    // Prices of each obstacle
    uint256[] public prices = [1000000000000000000, 1000000000000000000, 1000000000000000000];
    
    // Game Entry fee in Ewo token
    uint256 public fee;
    
    //Events
    event updatedFee(uint256 fee, address owner);
    
    constructor(address obstacleNFTAddress, address tokenAddress){
         nftcontract = IERC1155(obstacleNFTAddress);
         token = IERC20(tokenAddress);
         fee = 100;
    }
    
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
    
    function withdrawObstacles(uint256 obstacleId)  public onlyOwner{
        uint256 obstacles = (nftcontract).balanceOf(address(this), obstacleId);
        address owner = owner();
        (nftcontract).safeTransferFrom(address(this), owner, obstacleId, obstacles, "");
    }
    
    function buyObstacle(uint8 obstacleId) public payable {      //can remove payable
        require(obstacleId < 3, "obstacle_id does not exist");
        require((nftcontract).balanceOf(msg.sender, obstacleId) < 2, "You cannot buy more NFTs");
        uint256 price = prices[obstacleId];
        require((token).transferFrom(msg.sender, address(this), price));
        uint256 tokenid = _sold[obstacleId];
        _tokenid[obstacleId][msg.sender] = tokenid; // token id
        _owners[obstacleId][tokenid] = msg.sender;  // to keep track of owners of each tokenid
        _sold[obstacleId] += 1;
        (nftcontract).safeTransferFrom(address(this), msg.sender, obstacleId, 1, "");
    }
    
    function changeFee(uint256 _newfee) external onlyOwner{
        fee = _newfee;
        emit updatedFee(fee, msg.sender);
    } 
    
    // function setObstacleWinners(address w1, address w2, address w3) onlyOwner{
        
    // }
}
