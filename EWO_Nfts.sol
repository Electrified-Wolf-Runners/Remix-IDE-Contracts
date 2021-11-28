// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EWO_Nfts is ERC1155Supply, Ownable{
    // Obstacle and land ids
    uint256 public constant GREEN_DUSTBIN = 0;
    uint256 public constant RED_BAR = 1;
    uint256 public constant BLUE_BAR = 2;
    uint256 public constant LAND = 3;

    IERC20 token;

    // Mapping from obstacle id to token ID to owner address
    mapping(uint256 => mapping (uint256 => address)) private _owners;

    // Mapping from obstacle_id to Owner address to token_id 
    mapping(uint8 => mapping (address => uint256)) public _tokenid;
    
    // Mapping from obstacle_id to obstacles sold 
    mapping (uint8 => uint256) public _sold;

    // Prices of each obstacle and land
    uint256[] public prices = [1000000000000000000, 1000000000000000000, 1000000000000000000, 1000000000000000000]; //can change price later

    address public feeRecipient;
    
    constructor(address tokenAddress, address _feeRecipient) ERC1155("https://token-cdn-domain/") {
        // _mint(msg.sender, GREEN_DUSTBIN, 10, "");
        // _mint(msg.sender, RED_BAR, 10, "");
        // _mint(msg.sender, BLUE_BAR, 10, "");
        token = IERC20(tokenAddress);
        feeRecipient = _feeRecipient;
    }
    
    function withdrawObstacles(uint256 obstacle_id) public onlyOwner() {
        uint256 obstacles = balanceOf(address(this), obstacle_id);
        address owner = owner();
        this.safeTransferFrom(address(this), owner, obstacle_id, obstacles, "");
    }

    function buyObstacle(uint8 obstacleId) public {      //can remove payable
        require(obstacleId < 3, "obstacle_id does not exist");
        // require(balanceOf(msg.sender, obstacleId) < 2, "You cannot buy more NFTs"); // comment for demonstration purposes
        uint256 price = prices[obstacleId];
        uint256 tokenid = _sold[obstacleId];
        _tokenid[obstacleId][msg.sender] = tokenid; // token id
        _owners[obstacleId][tokenid] = msg.sender;  // to keep track of owners of each tokenid
        _sold[obstacleId] += 1;
        _mint(msg.sender, obstacleId, 1, "");
        require((token).transferFrom(msg.sender, feeRecipient, price));
    }

    function buyLand() public {      //can remove payable
        uint8 landId = 3;
        uint256 price = prices[landId];
        uint256 tokenid = _sold[landId];
        _tokenid[landId][msg.sender] = tokenid; // token id
        _owners[landId][tokenid] = msg.sender;  // to keep track of owners of each tokenid
        _sold[landId] += 1;
        _mint(msg.sender, landId, 1, "");
        require((token).transferFrom(msg.sender, feeRecipient, price));
    }

    function ownerOf(uint8 obstacle_id, uint256 tokenId) public view virtual returns (address) {
        address owner = _owners[obstacle_id][tokenId];
        require(owner != address(0), "ERC1155: owner query for nonexistent token");
        return owner;
    }
}
