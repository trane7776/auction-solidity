// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./IERC20Metadata.sol";

import {IERC20Errors} from "./ERC20Errors.sol";

abstract contract ERC20 is IERC20, IERC20Metadata, IERC20Errors {

  mapping(address account => uint256) private _balances;

  mapping(address account => mapping(address spender => uint256)) private _allowances;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;

  constructor(string memory name_, string memory symbol_) {
    _name = name_;
    _symbol = symbol_;
  }

  /**
   * @dev Returns the name of the token.
   */
  function name() public view virtual returns (string memory) {
    return _name;
  }

  /**
   * @dev Returns the symbol of the token, usually a shorter version of the
   * name.
   */
  function symbol() public view virtual returns (string memory) {
    return _symbol;
  }

  /**
   * @dev Returns the number of decimals used to get its user representation.
   * For example, if `decimals` equals `2`, a balance of `505` tokens should
   * be displayed to a user as `5.05` (`505 / 10 ** 2`).
   *
   * Tokens usually opt for a value of 18, imitating the relationship between
   * Ether and Wei. This is the default value returned by this function, unless
   * it's overridden.
   *
   * NOTE: This information is only used for _display_ purposes: it in
   * no way affects any of the arithmetic of the contract, including
   * {IERC20-balanceOf} and {IERC20-transfer}.
   */
  function decimals() public view virtual returns (uint8) {
    return 18;
  }

  /**
   * @dev See {IERC20-totalSupply}.
   */
  function totalSupply() public view virtual returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {IERC20-balanceOf}.
   */
  function balanceOf(address account) public view virtual returns (uint256) {
    return _balances[account];
  }  

  function allowance(address owner, address spender) public view virtual returns (uint256) {
    return _allowances[owner][spender];
  }

  function transfer(address to, uint256 value) public virtual returns (bool) {
    address owner = msg.sender;
    _transfer(owner, to, value);
    return true;
  }

  function approve(address spender, uint256 value) public virtual returns (bool) {
    address owner = msg.sender;
    _approve(owner, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
    address spender = msg.sender;
    _spendAllowance(from, spender, value);
    _transfer(from, to, value);
    return true;
  }


  function _transfer(address from, address to, uint256 value) internal {
    if (from == address(0)) {
        revert ERC20InvalidSender(address(0));
    }
    if (to == address(0)) {
        revert ERC20InvalidReceiver(address(0));
    }
    _update(from, to, value);
  }

  // MINT: 
  // FROM == address(0)
  // BURN:
  // TO == address(0)
  function _update(address from, address to, uint256 value) internal virtual {
    if (from == address(0)) {
        // Overflow check required: The rest of the code assumes that totalSupply never overflows
        _totalSupply += value;
    } else {
        uint256 fromBalance = _balances[from];
        if (fromBalance < value) {
            revert ERC20InsufficientBalance(from, fromBalance, value);
        }
        unchecked {
            // Overflow not possible: value <= fromBalance <= totalSupply.
            _balances[from] = fromBalance - value;
        }
    }

    if (to == address(0)) {
        unchecked {
            // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
            _totalSupply -= value;
        }
    } else {
        unchecked {
            // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
            _balances[to] += value;
        }
    }

    emit Transfer(from, to, value);
  }

  function _mint(address account, uint256 value) internal {
    if (account == address(0)) {
        revert ERC20InvalidReceiver(address(0));
    }
    _update(address(0), account, value);
  }

  function _burn(address account, uint256 value) internal {
    if (account == address(0)) {
        revert ERC20InvalidSender(address(0));
    }
    _update(account, address(0), value);
  }

  function _approve(address owner, address spender, uint256 value) internal {
    _approve(owner, spender, value, true);
  }


  function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
    if (owner == address(0)) {
        revert ERC20InvalidApprover(address(0));
    }
    if (spender == address(0)) {
        revert ERC20InvalidSpender(address(0));
    }
    _allowances[owner][spender] = value;
    if (emitEvent) {
        emit Approval(owner, spender, value);
    }
  }

  function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
    uint256 currentAllowance = allowance(owner, spender);
    if (currentAllowance < type(uint256).max) {
        if (currentAllowance < value) {
            revert ERC20InsufficientAllowance(spender, currentAllowance, value);
        }
        unchecked {
            _approve(owner, spender, currentAllowance - value, false);
        }
    }
  }



}