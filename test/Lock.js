const {expect} = require('chai');
const {ethers} = require('hardhat');


describe("Token-Launchpad Contract", function () {
    let Token, token, owner, user1 ,buyer,user2
    beforeEach(async function () {
        Token = await ethers.getContractFactory("TokenLaunchpad");
        [owner, user1, user2, buyer] = await ethers.getSigners();
        token = await Token.deploy();
    });
    
    

    it("Should launch a new token successfully", async function () {
        await expect(token.connect(owner).launchToken("TestToken", "TTK", 1000, ethers.parseEther("0.01")))
            .to.emit(token, "TokenLaunched");

        let allTokens = await token.getAllTokens();
        expect(allTokens.length).to.equal(1);
        let tokenInfo = await token.launchedTokens(allTokens[0]);
        // expect(tokenInfo.owner).to.equal(owner.address);
        expect(tokenInfo.totalSupply).to.equal(1000);

        await expect(token.connect(user1).launchToken("TestToken", "TTK", 1000,ethers.parseEther("0.01")))
        .to.emit(token, "TokenLaunched");

     allTokens = await token.getAllTokens();
    expect(allTokens.length).to.equal(2);
     tokenInfo = await token.launchedTokens(allTokens[1]);
    // expect(tokenInfo.owner).to.equal(user1.address);
    expect(tokenInfo.totalSupply).to.equal(1000);
    });

    it("buy token", async function(){
       await expect(token.launchToken("dhruv","dd",10000000,ethers.parseEther("0.01"))).to.emit(token,"TokenLaunched");  
       let allToken2 = await token.getAllTokens();
       expect(allToken2.length).to.equal(1);
       const tokenAddress = allToken2[0];
       let boughtToken = 1001;
       let ethSenToBuyToken = (boughtToken * 0.01).toString();
       expect(token.connect(user1).buyTokens(tokenAddress, boughtToken, { value: ethers.parseEther(ethSenToBuyToken) })).to.emit(token, "TokensPurchased")

       const erc20 = await ethers.getContractAt("ERC20Token", tokenAddress);

       const user1TokenBalance = await erc20.balanceOf(user1.address);


       expect(user1TokenBalance).to.equal(boughtToken);

    })
	
    it("should allow user to sell tokens back to token owner", async function () {
        // Launch token
        await token.connect(owner).launchToken("TestToken", "TTK", 1000, ethers.parseEther("0.01"));
        const allTokens = await token.getAllTokens();
        const launchedTokenAddress = allTokens[0];
    
        const erc20 = await ethers.getContractAt("ERC20Token", launchedTokenAddress);
    
        // Owner approves TokenLaunchpad to transfer tokens
        await erc20.connect(owner).approve(token.target, 1000000);
    
        // Buy tokens from Launchpad (user1)
        const buyAmount = 1000;
        const totalCost = (buyAmount * 0.01).toString();
        await token.connect(user1).buyTokens(launchedTokenAddress, buyAmount, {
            value: ethers.parseEther(totalCost),
        });
    
        const sellAmount = 500;
        const sellValue = ethers.parseEther((sellAmount * 0.01).toString());
    
        // Owner sends ETH to launchpad to allow sell
        await owner.sendTransaction({ to: token.target, value: sellValue });
    
        // Approve token transfer for selling
        await erc20.connect(user1).approve(token.target, sellAmount);
    
        // Check balances before sell
        const beforeEth = await ethers.provider.getBalance(user1.address);
        const beforeTokenBalance = await erc20.balanceOf(user1.address);
        console.log("Before Sell => User ETH:", ethers.formatEther(beforeEth), "User Tokens:", beforeTokenBalance.toString());
    
        // Sell tokens
        const tx = await token.connect(user1).sellTokens(launchedTokenAddress, sellAmount);
        const receipt = await tx.wait();
        const gasUsed = receipt.gasUsed * receipt.gasPrice;
    
        // Check balances after sell
        const afterEth = await ethers.provider.getBalance(user1.address);
        const afterTokenBalance = await erc20.balanceOf(user1.address);
        console.log("After Sell => User ETH:", ethers.formatEther(afterEth), "User Tokens:", afterTokenBalance.toString());
    
        // Assertions
        expect(afterTokenBalance).to.equal(buyAmount - sellAmount);
        expect(afterEth).to.be.above(beforeEth - gasUsed);
    });
    
    
})