// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.23;

import {IERC20Metadata, IERC20Errors} from './IERC20.sol';

contract ERC20Token is IERC20Metadata, IERC20Errors {
  address private immutable owner; 
  uint8 public constant decimals = 18;

  string public name;
  string public symbol;

  uint256 public totalSupply;

  mapping(address account => uint256 balance) public balanceOf;
  mapping(address owner => mapping(address spender => uint256 value)) public allowance;

  constructor (string memory _name, string memory _symbol, uint256 _totalSupply) payable {
    owner = msg.sender;
    name = _name;
    symbol = _symbol;

    mint(_totalSupply);
  }

  function approve(address spender, uint256 value) external returns (bool){
    allowance[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transfer(address to, uint256 value) external returns (bool){
    address sender = msg.sender;
    uint256 senderBalance = balanceOf[sender];

    if(to == address(0)){
      revert ERC20InvalidReceiver(to);
    }

    if(value > senderBalance){
      revert ERC20InsufficientBalance(sender, senderBalance, value);
    }

    unchecked{
        balanceOf[sender] -= value;
        balanceOf[to] += value;
    }

    emit Transfer(sender, to, value);

    return true;
  }

  function transferFrom(address from, address to, uint256 value) external returns (bool){
    address spender = msg.sender;
    uint _allowance = allowance[from][spender];
    uint balanceFrom = balanceOf[from];
    if(to == address(0)){
      revert ERC20InvalidReceiver(to);
    }
    if(value > _allowance){
      revert ERC20InsufficientAllowance(spender, _allowance, value);
    }
    if(value > balanceFrom){
      revert ERC20InsufficientBalance(from, balanceFrom, value);
    }
    unchecked{
        allowance[from][spender] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;
    }

    emit Transfer(from, to, value);

    return true;
  }

  modifier onlyOwner {
    require(msg.sender == owner, 'Only owner can do this!');
    _;
  }

  function mint(uint256 value) public payable onlyOwner {
    unchecked{
        balanceOf[owner] += value;
        totalSupply += value;
    }

    emit Transfer(address(0), owner, value);
  }

  function mint(uint256 value, address to) public payable onlyOwner {
    unchecked{
        balanceOf[to] += value;
        totalSupply += value;
    }

    emit Transfer(address(0), to, value);
  }

  function burn(uint256 value) public payable onlyOwner {
    address sender = msg.sender;
    uint256 senderBalance = balanceOf[sender];

    if(value > senderBalance){
      revert ERC20InsufficientBalance(sender, senderBalance, value);
    }
    
    unchecked{
        balanceOf[sender] -= value;
        totalSupply -= value;
    }

    emit Transfer(sender, address(0), value);
  }
}