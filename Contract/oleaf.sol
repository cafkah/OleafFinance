Sender()][spender] = amount;
        emit Approval(_msgSender(), spender, amount);

        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - sender and recipient cannot be the zero address.
     * - sender must have a balance of at least amount.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * amount.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {

        _transfer(sender,recipient,amount);

        require(amount <= _allowances[sender][_msgSender()],"OleafToken: Check for approved token count failed");
        
        _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()].sub(amount);

        emit Approval(sender, _msgSender(), _allowances[sender][_msgSender()]);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        
        require(recipient != address(0),"OleafToken: Cannot have recipient as zero address");
        require(sender != address(0),"OleafToken: Cannot have sender as zero address");
        require(_balances[sender] >= amount,"OleafToken: Insufficient Balance" );
        require(_balances[recipient] + amount >= _balances[recipient],"OleafToken: Balance check failed");
        
        // update the unlocked tokens based on time if required
        _updateUnLockedTokens(sender, amount);
        _unlockedTokens[sender] = _unlockedTokens[sender].sub(amount);
        _unlockedTokens[recipient] = _unlockedTokens[recipient].add(amount);

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        
        emit Transfer(sender,recipient,amount);
    }

    function _transferLock(address sender, address recipient, uint256 amount) private {
        
        require(recipient != address(0),"OleafToken: Cannot have recipient as zero address");
        require(sender != address(0),"OleafToken: Cannot have sender as zero address");
        require(_balances[sender] >= amount,"OleafToken: Insufficient Balance" );
        require(_balances[recipient] + amount >= _balances[recipient],"OleafToken: Balance check failed");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        _unlockedTokens[sender] = _unlockedTokens[sender].sub(amount);

        emit Transfer(sender,recipient,amount);
    }
    
     /**
     * @dev Destroys amount tokens from the account.
     *
     * See {ERC20-_burn}.
     */
     
    function burn(address account, uint256 amount) public onlyOwner {

        require(account != address(0), "OleafToken: burn from the zero address");

        if( _balances[account] == _unlockedTokens[account]){
            _unlockedTokens[account] = _unlockedTokens[account].sub(amount, "OleafToken: burn amount exceeds balance");
        }

        _balances[account] = _balances[account].sub(amount, "OleafToken: burn amount exceeds balance");

        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, address(0), amount);

        if(account != _msgSender()){
            
            require(amount <= _allowances[account][_msgSender()],"OleafToken: Check for approved token count failed");

            _allowances[account][_msgSender()] = _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance");
            emit Approval(account, _msgSender(), _allowances[account][_msgSender()]);
        }
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's _msgSender() to to _msgSender()
    // - Owner's _msgSender() must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // - takes in locking Period to lock the tokens to be used
