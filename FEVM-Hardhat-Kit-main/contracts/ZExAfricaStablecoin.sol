// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
/// @title XRC20/ERC20/TRC20 Standard stablecoin
contract ZExAfricaStablecoin{

    uint8 public tokenDecimals;
    uint256 private totalTokenSupply;
    string public tokenName;
    string public tokenSymbol;
    string public peggedCurrency;
    address public deployerAddress;

    mapping (address => uint) private addressBalance;
    mapping (address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event TokenCreated(address indexed _contractAddress, address indexed _deployerAddress, string _name, string _symbol, uint8 _decimals);
    event FunctionCannotBeCalled(address _contractAddress, address _functionCaller, string message);

    error RevertTransaction(string _error, string _solution);

    modifier OnlyDeployer(){
        string memory message = "Only the 0xAfrica DEX can call this method";
        require(msg.sender == deployerAddress, message);
        _;
    }

    modifier NotZeroAddress(){
        string memory message = "Zero address cannot call the function";
        require(msg.sender != address(0), message);
        _;
    }

    modifier ShouldHaveAvailableBalance(address _address, uint256 transactionAmount){
        string memory message = "Balance needs to be greater than the transaction amount";
        require(addressBalance[msg.sender] > transactionAmount, message);
        _;
    }

    modifier ShouldHaveEnoughAllowance(address _from, address _to, uint256 _value){
        require(allowances[_from][msg.sender] >= _value, "You do not have enough allowance to spend.");
        _;
    }

    constructor(string memory _name, string memory _symbol, string memory _peggedCurrency){
        deployerAddress = msg.sender;
        tokenName = _name;
        tokenSymbol = _symbol;
        peggedCurrency = _peggedCurrency;
        tokenDecimals = 18;
        totalTokenSupply = 0;
        emit TokenCreated(address(this), deployerAddress, tokenName, tokenSymbol, tokenDecimals);
    }

    function name() public view returns (string memory _name){
        _name = tokenName;
    }

    function symbol() public view returns (string memory _symbol){
        _symbol = tokenSymbol;
    }

    function decimals() public view returns (uint8 _decimals){
        _decimals = tokenDecimals;
    }

    function totalSupply() public view returns (uint256 _tokenSupply){
        _tokenSupply = totalTokenSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance){
        balance = addressBalance[_owner];
    }

    function transfer(address _to, uint256 _value) public ShouldHaveAvailableBalance(msg.sender, _value) NotZeroAddress returns (bool success){
        addressBalance[msg.sender] -= _value;
        addressBalance[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function mintNewTokens(address _mintTo, uint256 _value) external OnlyDeployer returns(bool success){
        totalTokenSupply += _value;
        addressBalance[_mintTo] += _value;
        return true;
    }

    function burnTokens(address _burnFrom, uint256 _value) external OnlyDeployer ShouldHaveAvailableBalance(_burnFrom, _value) NotZeroAddress returns(bool success){
        totalTokenSupply -= _value;
        addressBalance[_burnFrom] -= _value;
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external ShouldHaveEnoughAllowance(_from, _to, _value) returns (bool success){
        allowances[_from][msg.sender] -= _value;
        addressBalance[_from] -= _value;
        addressBalance[_to] += _value;
        emit Transfer(_from, _to, _value);
        success = true;
    }

    function approve(address _spender, uint256 _value) external returns (bool success){
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        success = true;
    }

    function allowance(address _owner, address _spender) external view virtual returns (uint256 remaining){
        return allowances[_owner][_spender];
    }

    fallback() external payable {
        raiseError("Function call non-existent.", "Please review the contract for the correct method to be called.");
    }

    receive() external payable{
        raiseError("Contract should not receive funds", "To provide liquidity, refer to the 0xAfrica DEX contract");
    }

    function raiseError(string memory _errorMessage, string memory _solutionMessage) internal pure {
        revert RevertTransaction({_error: _errorMessage, _solution: _solutionMessage});
    }
}