// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "./ZExAfricaStablecoin.sol"; 
import "./ZExAfricaOracle.sol";
import "./ZExAfricaLiquidityToken.sol";

interface IZExAfricaOracle {

    function getRate(string memory _tokenName) external view returns(uint256);

}

/// @title Main deployer and DEX contract
contract ZExAfricaDEX {
    
    uint256 public transactionFee;
    uint256 public minimumLiquidityContributionAmount;
    uint256 public totalFeesCollected;
    uint256 public currentLiquidityAmount;

    address public manager;

    address public oracleAddress;

    IZExAfricaOracle priceFeedOracle;

    ZExAfricaLiquidityToken liquidityTokenContract;

    mapping (string => ZExAfricaStablecoin) public tokenContractsDeployed;

    event NewStablecoinDeployed(string _tokenName, string _tokenSymbol, address _tokenAddress, string _peggedCurrency);
    event TransactionFeeUpdated(uint256 _feeAmount);
    event TokenSwapInitiated(address _for, string _tokenName, uint _value);
    event LowLiquidity(address _tokenAddress, string _tokenName, string _reason);
    event TokensSwapped(address indexed _contract, string _tokenName, uint256 _sendersNewBalance);
    event LiquidityAddedToDEX(address _provider, uint256 _amount, uint256 _providerBalance, uint _contractBalance);
    event LiquidityWithdrawn(address _provider, uint256 _amountWithdrawn, uint256 _providersBalance);
    event MinimumLiquidityContributionSet(uint256 _amount);
    event LiquidityRewardsDistributed(uint _totalDistribution);
    event RewardWithdrawn(address _providerAddress, uint256 _amountWithdrawn, uint256 _providerBalance);
    event ProviderDoesNotQualifyForReward(address indexed _provider, uint256 _providerBalance);

    error TokenNameRequired(string _error, string _solution);
    
    modifier OnlyManager(string memory _message){
        require(msg.sender == manager, _message);
        _;
    }

    modifier ContractExists(string memory _name){
        require(address(tokenContractsDeployed[_name]) != address(0), "The requested token contract does not exist or has not been deployed as yet");
        _;
    }

    modifier ContractHasSufficientLiquidity(ZExAfricaStablecoin _contract, uint256 _value){
        require(checkLiquidity(_contract, _value) == true, "Liquidity is low at the moment!");
        _;
    }

    constructor(address _oracleAddress){
        oracleAddress = _oracleAddress;
        manager = msg.sender;
        priceFeedOracle = IZExAfricaOracle(oracleAddress);
        liquidityTokenContract = new ZExAfricaLiquidityToken("0xAfrica Liquidity Token", "0xAL");
    }

    function getTransactionFee()public view returns(uint256 _fee){
        _fee = transactionFee;
    }

    function setTransactionFee(uint256 _feeAmount) public returns(uint256){
     transactionFee = _feeAmount;
        return transactionFee;
    }

    function getExchangeRate(string memory _tokenName) public view returns(uint256 _rate){
        _rate = priceFeedOracle.getRate(_tokenName);
    }

    function getMinimumContributionAmount() public view returns(uint256 _amount){
        _amount = minimumLiquidityContributionAmount;
    }

    function setMinimumContributionAmount(uint256 _amount) external OnlyManager("Only the manager can set min contribution amount."){
        minimumLiquidityContributionAmount = _amount;
        emit MinimumLiquidityContributionSet(minimumLiquidityContributionAmount);
    }

    function getStablecoinContractAddress(string memory _name) public view ContractExists(_name) returns(address _contractAddress){
        _contractAddress = address(tokenContractsDeployed[_name]);
    }

    function deployStablecoin(string memory _name, string memory _symbol, string memory _peggedCurrency) external OnlyManager("Only the manager or delgated authority can deploy a new stablecoin") returns(bool){
        tokenContractsDeployed[_name] = new ZExAfricaStablecoin(_name, _symbol, _peggedCurrency);
        emit NewStablecoinDeployed(_name, _symbol, address(tokenContractsDeployed[_name]), _peggedCurrency);
        return true;
    }

    function onRamp(address _sender, uint256 _value, ZExAfricaStablecoin _contract) internal ContractHasSufficientLiquidity(_contract, _value) returns(bool success){
        //get the exchange rate. 
        uint256 _rate = priceFeedOracle.getRate(_contract.name());
        //calculate the amount to be minted based on the native token that was sent.
        uint256 _amountToBeMinted = _value * _rate;
        //call the mint method on the _contract
        _contract.mintNewTokens(_sender, _amountToBeMinted);
        //then call the balanceOf method and return the senders new balance of that particular stablecoin.
        emit TokensSwapped(address(_contract), _contract.name(), _contract.balanceOf(_sender));
        currentLiquidityAmount += _value;
        return true;
    }

    function deductTransactionFee(uint _transactionValue) internal returns(uint256){
        require(_transactionValue > transactionFee, "The transaction amount should be higher than the transaction fee.");
        uint256 _transactionValueMinusFee = _transactionValue - transactionFee;
        totalFeesCollected += transactionFee;
        return _transactionValueMinusFee;
    }

    function swapToken(string memory _tokenName) external payable ContractExists(_tokenName) returns(uint256){
        uint256 _valueToBeSwapped = deductTransactionFee(msg.value);
        emit TokenSwapInitiated(msg.sender, _tokenName, _valueToBeSwapped);
        onRamp(msg.sender, _valueToBeSwapped, tokenContractsDeployed[_tokenName]);
        return tokenContractsDeployed[_tokenName].balanceOf(msg.sender);
    }

    receive() external payable {
        revert TokenNameRequired({_error: "Receive method does not accept args. Token name is required to process a swap", 
                                _solution: "The swapToken(string _tokenName) method should be called in order to process the swap"});
    }

    function checkLiquidity(ZExAfricaStablecoin _contract, uint _tentativeAmountToBeMinted) internal returns(bool){
        uint256 nativeTokenBalanceInFactory = address(this).balance;
        uint256 stablecoinCurrentSupplyIfSwapIsSuccessful = _contract.totalSupply() + _tentativeAmountToBeMinted;
        uint256 _rate = priceFeedOracle.getRate(_contract.name());
        require(_rate != 0, "Rate cannot be zero, Pricefeed Oracle returned 0");
        if (nativeTokenBalanceInFactory >= stablecoinCurrentSupplyIfSwapIsSuccessful*priceFeedOracle.getRate(_contract.name())){
            return true;
        }
        emit LowLiquidity(address(_contract), _contract.name(), "Current liquidity is below the minimum threshold, swap cannot be processed at the moment.");
        return false;
    }

    function provideLiquidity() external payable {
        require(msg.value >= minimumLiquidityContributionAmount);
        liquidityTokenContract.mintNewTokens(msg.sender, msg.value);
        currentLiquidityAmount += msg.value;
        emit LiquidityAddedToDEX(msg.sender, msg.value, liquidityTokenContract.balanceOf(msg.sender), address(this).balance);
    }

    function withdrawLiquidity(uint256 _withdrawalAmount) external returns(uint256 _newProviderBalance){
        require(liquidityTokenContract.balanceOf(msg.sender) != 0, "Sender does not have an available balance.");
        require(msg.sender != address(0), "Zero address cannot transact on this method.");
        require(providerBalanceGreaterThanMinimumAmountOrEqualToZeroOnWithdrawal(_withdrawalAmount, liquidityTokenContract.balanceOf(msg.sender)), 
            "When withdrawing liquidity, your liquidity balance remaining after withdrawal needs to be greater than the minimum liquidity amount or equal to zero." );
        releaseRewards(_withdrawalAmount);
        currentLiquidityAmount -= _withdrawalAmount;
        emit LiquidityWithdrawn(msg.sender, _withdrawalAmount, liquidityTokenContract.balanceOf(msg.sender));
        return liquidityTokenContract.balanceOf(msg.sender);
    }

    function providerBalanceGreaterThanMinimumAmountOrEqualToZeroOnWithdrawal(uint256 _withdrawalAmount, uint256 _providerBalance) internal view returns(bool){
        if((_providerBalance - _withdrawalAmount) > minimumLiquidityContributionAmount || (_providerBalance - _withdrawalAmount) == 0){
            return true;
        }
        return false;
    }

    function releaseRewards(uint _amountWithdrawn) internal returns(bool _completed){
        require(_amountWithdrawn <= liquidityTokenContract.balanceOf(msg.sender), "You do not have sufficient balance to withdraw");
        uint256 _rewardPortion = totalFeesCollected / liquidityTokenContract.totalSupply();
        liquidityTokenContract.burnTokens(msg.sender, _amountWithdrawn);
        payable(msg.sender).transfer(_rewardPortion*_amountWithdrawn);
        _completed = true;
    }
}