// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20Token.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "hardhat/console.sol";

contract TokenLaunchpad {
    struct TokenInfo {
        address tokenAddress;
        uint256 pricePerToken;
        uint256 totalSupply;
    }

    mapping(address => TokenInfo) public launchedTokens;
    address[] public allTokens;

    event TokenLaunched(address indexed token, uint256 supply, uint256 price);
    event TokensPurchased(address indexed buyer, address token, uint256 amount, uint256 cost);
    event TokensSold(address indexed seller, address token, uint256 amount, uint256 ethReturned);

    function launchToken(string memory name, string memory symbol, uint256 supply, uint256 price) public {
        require(supply > 0, "Supply must be greater than zero");
        require(price > 0, "Price must be greater than zero");

        ERC20Token newToken = new ERC20Token(name, symbol, supply);
        launchedTokens[address(newToken)] = TokenInfo(address(newToken), price, supply);
        allTokens.push(address(newToken));

        emit TokenLaunched(address(newToken), supply, price);
    }

    function buyTokens(address token, uint256 amount) public payable {
        TokenInfo storage info = launchedTokens[token];
        require(info.tokenAddress != address(0), "Token not found");
        require(msg.value >= (amount * info.pricePerToken) / 10**18, "Incorrect ETH sent");

        ERC20Token erc20 = ERC20Token(token);
        require(erc20.balanceOf(address(this)) >= amount, "Not enough tokens in contract");

        erc20.transfer(msg.sender, amount);

        emit TokensPurchased(msg.sender, token, amount, msg.value);
    }

    // function sellTokens(address token, uint256 amount) public {
    //     TokenInfo storage info = launchedTokens[token];
    //     require(info.tokenAddress != address(0), "Token not found");

    //     uint256 ethToReturn = amount * info.pricePerToken  / 10**18;
    //     require(address(this).balance >= ethToReturn, "Not enough ETH in contract");
    
    //     ERC20Token erc20 = ERC20Token(token);
    //     require(erc20.allowance(msg.sender, address(this)) >= amount, "Allowance too low");
    //     require(erc20.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

    //     payable(msg.sender).transfer(ethToReturn);

    //     emit TokensSold(msg.sender, token, amount, ethToReturn);
    // }

        function sellTokens(address token, uint256 amount) public {
        console.log("sellTokens called by:", msg.sender);
        console.log("Token address:", token);
        console.log("Amount to sell:", amount);

        TokenInfo storage info = launchedTokens[token];
        console.log("Token exists in mapping:", info.tokenAddress != address(0));
        require(info.tokenAddress != address(0), "Token not found");

        console.log("Token price per token:", info.pricePerToken);
        uint256 ethToReturn = amount * info.pricePerToken / 10**18;
        console.log("ETH to return:", ethToReturn);
        console.log("Contract ETH balance:", address(this).balance);
        require(address(this).balance >= ethToReturn, "Not enough ETH in contract");
    
        ERC20Token erc20 = ERC20Token(token);
        uint256 allowance = erc20.allowance(msg.sender, address(this));
        console.log("Token allowance:", allowance);
        require(allowance >= amount, "Allowance too low");

        console.log("Seller token balance before:", erc20.balanceOf(msg.sender));
        console.log("Contract token balance before:", erc20.balanceOf(address(this)));
        
        bool transferSuccess = erc20.transferFrom(msg.sender, address(this), amount);
        console.log("TransferFrom result:", transferSuccess);
        require(transferSuccess, "Token transfer failed");

        console.log("Seller token balance after:", erc20.balanceOf(msg.sender));
        console.log("Contract token balance after:", erc20.balanceOf(address(this)));

        console.log("About to transfer ETH to seller");
        payable(msg.sender).transfer(ethToReturn);
        console.log("ETH transferred to seller");

        emit TokensSold(msg.sender, token, amount, ethToReturn);
        console.log("TokensSold event emitted");
          console.log("Contract ETH balanceafter sell:", address(this).balance);
    }

    function addLiquidityToDex(
        address router,
        address token,
        uint256 tokenAmount
    ) external payable {
        require(router != address(0), "Router address is zero");
        require(tokenAmount > 0 && msg.value > 0, "Invalid amounts");

        ERC20 tokenContract = ERC20(token);
        require(tokenContract.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");

        tokenContract.approve(router, tokenAmount);

        IUniswapV2Router02 dexRouter = IUniswapV2Router02(router);
        dexRouter.addLiquidityETH{value: msg.value}(
            token,
            tokenAmount,
            0,
            0,
            msg.sender,
            block.timestamp + 300
        );
    }

    function getAllTokens() public view returns (address[] memory) {
        return allTokens;
    }

    receive() external payable {}

}
