// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract ZExAfricaOracle {

    mapping (string => uint256) exchangeRate;

    address public Owner;

    address public Admin;

    modifier OnlyOwnerOrAdmin(address _caller){
        require((_caller == Owner || _caller == Admin) && _caller != address(0), "You are not the contract Owner or Administrator");
        _;
    }

    modifier IsRateAvailable(string memory _tokenName){
        require(exchangeRate[_tokenName] != 0, "Exchange rate has not been set for this token");
        _;
    }
    
    event NewRateSet(string _tokenName, uint256 _oldRate, uint256 _newRate);

    constructor() {
        Owner = msg.sender;
    }

    function getRate(string memory _tokenName) external view IsRateAvailable(_tokenName) returns(uint256 _rate){
        _rate = exchangeRate[_tokenName];
    }

    function setRate(string memory _tokenName, uint256 _newRate) external OnlyOwnerOrAdmin(msg.sender) returns(uint256 _rate){
        uint256 _oldRate = exchangeRate[_tokenName];
        exchangeRate[_tokenName] = _newRate;
        emit NewRateSet(_tokenName, _oldRate, _newRate);
        _rate = _newRate;
    }
}