// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Use GitHub imports (Remix-friendly)
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract GreenLoopToken is ERC20, Ownable {
    uint256 public tokenToUsdRate = 1; // 1 GLPT = 1 USD (simulated)
    mapping(address => uint256) public usdBalances;

    event Minted(address indexed to, uint256 amount, string reason);
    event Exchanged(address indexed user, uint256 glptAmount, uint256 usdAmount);
    event UsdFunded(address indexed user, uint256 amount);
    event ExchangeRateUpdated(uint256 newRate);

    constructor(uint256 initialSupply) ERC20("Green Loop Project Token", "GLPT") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    // Mint tokens to user based on verified e-waste input
    function mintTokens(address to, uint256 amount, string memory reason) external onlyOwner {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be positive");
        _mint(to, amount * 10 ** decimals());
        emit Minted(to, amount, reason);
    }

    // Simulate funding user's USD balance (admin only)
    function fundUsd(address user, uint256 amount) external onlyOwner {
        require(user != address(0), "Cannot fund zero address");
        usdBalances[user] += amount;
        emit UsdFunded(user, amount);
    }

    // Exchange GLPT to simulated USD balance
    function exchangeTokensForUSD(uint256 glptAmount) external {
        require(glptAmount > 0, "Amount must be positive");
        uint256 amountInWei = glptAmount * 10 ** decimals();
        require(balanceOf(msg.sender) >= amountInWei, "Not enough GLPT");

        uint256 usdEquivalent = glptAmount * tokenToUsdRate;

        _burn(msg.sender, amountInWei);
        usdBalances[msg.sender] += usdEquivalent;

        emit Exchanged(msg.sender, glptAmount, usdEquivalent);
    }

    // View simulated USD balance
    function getUsdBalance(address user) external view returns (uint256) {
        return usdBalances[user];
    }

    // Admin can update exchange rate (e.g., due to market simulation)
    function updateExchangeRate(uint256 newRate) external onlyOwner {
        require(newRate > 0, "Exchange rate must be positive");
        tokenToUsdRate = newRate;
        emit ExchangeRateUpdated(newRate);
    }

}
