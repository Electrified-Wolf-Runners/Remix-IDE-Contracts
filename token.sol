// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.5;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EWO_Token is ERC20{
    constructor() ERC20("EWO_Token", "EWO"){
        _mint(msg.sender, 10 * ( 10 ** uint256(decimals())));
    }
    
    function mint() public returns (bool) {
        _mint(msg.sender, 1000 * ( 10 ** uint256(decimals())));
        return true;
    }

}
