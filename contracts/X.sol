// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract XenniumToken is ERC20, Ownable, ERC20Permit {
    uint256 private constant TOTAL_SUPPLY = 19_000_000 * 10**18;  // 19 million tokens
    uint256 private constant OWNER_RESERVE = 1_000_000 * 10**18;  // 1 million tokens reserved for the owner

    // Declare the event for withdrawal
    event Withdraw(address indexed recipient, uint256 amount);

    constructor() ERC20("Xennium", "XENX") ERC20Permit("Xennium") Ownable(msg.sender) {
        _mint(msg.sender, OWNER_RESERVE); // Reserve 1 million tokens for the owner
        _mint(address(this), TOTAL_SUPPLY - OWNER_RESERVE); // Mint remaining supply to the contract
    }
 
    // Prevent the last coin from being spent (Xennium special rule)
    function _safeTransferCheck(address from, uint256 amount) internal view {
        require(balanceOf(from) - amount >= 1, "XENX: Cannot spend the last coin");
    }

    // Override transfer with last coin check
    function transfer(address to, uint256 amount) public override returns (bool) {
        _safeTransferCheck(msg.sender, amount);
        return super.transfer(to, amount);
    }

    // Override transferFrom with last coin check
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        _safeTransferCheck(from, amount);
        return super.transferFrom(from, to, amount);
    }

    // Withdraw function to allow the contract owner to transfer tokens out of the contract
    function withdraw(address recipient, uint256 amount) external onlyOwner {
        _transfer(address(this), recipient, amount);
        emit Withdraw(recipient, amount);  // Emit withdraw event correctly
    }
}
