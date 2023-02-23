// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./IUSDT.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract swapDex {

    IUSDT internal Uni;
    IUSDT internal Dai;
    IUSDT internal Usdc;
    AggregatorV3Interface internal priceFeedDai;
    AggregatorV3Interface internal priceFeedEth;
    AggregatorV3Interface internal priceFeedUni;
    AggregatorV3Interface internal priceFeedUsdc;
    address admin;
    int DaiDecimals = 1e8;
    int EthDecimals = 1e8;
    int UniDecimals = 1e8;
    int UsdcDecimals = 1e8;

    uint totalEth;
    uint totalDai;
    uint totalUni;
    uint totalUsdc;

    mapping(address => mapping(address => uint)) private user2Token2Balance;
    mapping(address => address[]) private token2LiquidityProvider;

    constructor() {
        priceFeedDai = AggregatorV3Interface(0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9);
        priceFeedEth = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        priceFeedUni = AggregatorV3Interface(0x553303d460EE0afB37EdFf9bE42922D8FF63220e);
        priceFeedUsdc = AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6);
        Uni = IUSDT(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
        Dai = IUSDT(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        Usdc = IUSDT(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        admin = msg.sender;
    }

    function displayLiquidityProviders(address _addr) public view returns(address[] memory){
        address[] memory providers = token2LiquidityProvider[];
    }

    function checkUsdcBalance() public view {
        Usdc.balanceOf(address(this));
    }

    modifier OnlyAdmin() {
        require(msg.sender == admin, "NOT ADMIN");
        _;
    }

    function PriceCheck_ (int price1, int price2) pure internal {
       // require(price2 > 0 , "PRICE FEED CURRENTLY UNAVAILABLE");
    }

    function TransferEth (uint _amount, address payable _sender) internal returns(bool){
        payable(_sender).transfer(_amount/ 1e18);
        return true;
    }

    function withdrawDai(int _ammount) public OnlyAdmin() {
        transfer_(Dai, _ammount, msg.sender);
    }

    function withdrawUni(int _ammount) public OnlyAdmin() {
        transfer_(Uni, _ammount, msg.sender);
    }

    function withdrawUsdc(int _ammount) public OnlyAdmin() {
        transfer_(Usdc, _ammount, msg.sender);
    }

    function withdrawEth(int _ammount) public OnlyAdmin() {
        payable(msg.sender).transfer(uint(_ammount) * 1e18);
    }

    function BalanceOfDai() view public OnlyAdmin() {
        Dai.balanceOf(address(this));
    }

    function BalanceOfUni() view public OnlyAdmin() {
        Uni.balanceOf(address(this));
    }

    function BalanceOfUsdc() view public OnlyAdmin() {
        Usdc.balanceOf(address(this));
    }
 
    function addDaiLiquidity(uint _amount) public {
        addLiquidity(Dai, int(_amount), msg.sender, totalDai, 0x6B175474E89094C44Da98b954EedeAC495271d0F);
    }

    function addUniLiquidity(uint _amount) public {
        addLiquidity(Uni, int(_amount), msg.sender, totalUni, 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
    }

    function addUsdcLiquidity(uint _amount) public {
        addLiquidity(Usdc, int(_amount), msg.sender, totalUsdc, 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        totalUsdc += uint(_amount);
    }

    function swapEthToUni() payable public{
        swappEth(msg.value, priceFeedEth, priceFeedUni, Uni, totalUni);
    }

    function swapEthToDai() payable public{
        swappEth(msg.value, priceFeedEth, priceFeedDai, Dai, totalDai);
    }

    function swapEthToUsdc() payable public{
        swappEth(msg.value, priceFeedEth, priceFeedUsdc, Usdc, totalUsdc);
    }

    function swapUniToDai(uint UniToSwap) public {
        swapp2Tokens(UniToSwap, priceFeedUni, priceFeedDai, Uni, Dai, totalDai);
    }

    function swapUniToUsdc(uint UniToSwap) public {
        swapp2Tokens(UniToSwap, priceFeedUni, priceFeedUsdc, Uni, Usdc, totalUsdc);
    }

    function swapUniToEth(uint UniToSwap) public {
        swapToken2Eth(UniToSwap, priceFeedUni, priceFeedEth,  Uni);
    }

    function swapDaiToUni(uint DaiToSwap) public {
        swapp2Tokens(DaiToSwap, priceFeedDai, priceFeedUni, Dai, Uni, totalUni);
    }

    function swapDaiToUsdc(uint DaiToSwap) public {
        swapp2Tokens(DaiToSwap, priceFeedDai, priceFeedUsdc, Dai, Usdc, totalUsdc);
        
    }

    function swapDaiToEth(uint DaiToSwap) public {
        swapToken2Eth(DaiToSwap, priceFeedDai, priceFeedEth,  Dai);
    }

    function swapUsdcToUni(uint UsdcToSwap) public {
        swapp2Tokens(UsdcToSwap, priceFeedUsdc, priceFeedUni, Usdc, Uni, totalUni);
    }

    function swapUsdcToDai(uint UsdcToSwap) public {
        swapp2Tokens(UsdcToSwap, priceFeedUsdc, priceFeedDai, Usdc, Dai, totalDai);
    }

    function swapUsdcToEth(uint UsdcToSwap) public {
        swapToken2Eth(UsdcToSwap, priceFeedUsdc, priceFeedEth,  Usdc);
    }

    function getLatestPrice_ (AggregatorV3Interface _pricefeed) internal view returns(int){
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = _pricefeed.latestRoundData();
        return (price);
    }
    function getLatestPrice_E () public view returns(int){
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeedEth.latestRoundData();
        return (price / 1e8);
    }

    function transfer_ (IUSDT _token, int _ammount, address _to) internal returns(bool) {
       bool Status_ = _token.transfer(_to, uint(_ammount));
       require(Status_, "TRANSFER FAILED");
        return Status_;
    }

    function transferFrom_ (IUSDT _token, int _ammount, address _from) internal returns(bool) {
        bool Status_ = _token.transferFrom(_from, address(this), uint(_ammount));
        return Status_;
    }

    function addEthLiquidity() payable public {
        require(msg.value > 0, "INVALID TRANSFER AMOUNT");
        user2Token2Balance[msg.sender][address(0)] += msg.value;
        token2LiquidityProvider[address(0)].push(msg.sender);
    }

    function addLiquidity(IUSDT _token, int _ammount, address _from, uint _totalToken, address _tokenContract) internal {
        bool status = transferFrom_(_token, _ammount, _from);
        require (status, "TOKEN DEPOSIT FAILED");
        _totalToken += uint(_ammount);
        user2Token2Balance[_from][_tokenContract] += uint(_ammount);
        token2LiquidityProvider[_tokenContract].push(_from);
    }

    function swappEth(uint _amount, AggregatorV3Interface _priceFeedEth, AggregatorV3Interface _priceFeedT2, IUSDT token2, uint _totalToken) internal {
        require(_amount > 0, "INSUFFICIENT TRANSFERED AMOUNT");
        int EthPrice = getLatestPrice_(_priceFeedEth);
        int Token2Price = getLatestPrice_(_priceFeedT2);
        PriceCheck_(EthPrice, Token2Price);
        int token2Receive = ((int(_amount) * EthPrice ) / Token2Price);
        transfer_(token2, token2Receive, msg.sender);
       // _totalToken = _totalToken - (uint(token2Receive)/1e18);
    }

    function swapToken2Eth (uint _amount, AggregatorV3Interface _priceFeedT1, AggregatorV3Interface _priceFeedT2, IUSDT token1) internal {
        require(_amount > 0, "INVALID Uni AMOUNT TO SWAP");
        int price1 = getLatestPrice_(_priceFeedT1);
        int price2 = getLatestPrice_(_priceFeedT2);
        PriceCheck_(price1, price2);
        int EthToReceive = ((int(_amount) * price1) / price2);
        bool status = transferFrom_(token1, int(_amount), msg.sender);
        require(status, "TOKEN DEPOSIT FAILED");
        TransferEth(uint (EthToReceive), payable (msg.sender));
    }

    function swapp2Tokens(uint _amount, AggregatorV3Interface _priceFeedT1, AggregatorV3Interface _priceFeedT2, IUSDT token1, IUSDT token2, uint _totalToken) internal {
        require(_amount > 0, "INSUFFICIENT AMMOUNT TO SWAP");
        int price1 = getLatestPrice_(_priceFeedT1);
        int price2 = getLatestPrice_(_priceFeedT2);
        PriceCheck_(price1, price2);
        int token2Receive = ((int (_amount) * price1) / price2);
       // require (int(_totalToken) <= token2Receive, "INSUFFICIENT LIQUIDITY AT THE MOMENT");
        bool status = transferFrom_(token1, int(_amount), msg.sender);
        require(status, "TOKEN DEPOSIT FAILED");
        transfer_(token2, token2Receive, msg.sender);
        _totalToken -= uint(token2Receive / 1e18);
    }
}