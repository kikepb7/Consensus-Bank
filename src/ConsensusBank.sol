// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ConsensusBank { 

    struct Account {
        uint256 balance;
        uint256 lastUpdate;
    }

    struct Loan {
        uint256 amount;
        uint256 lastUpdate;
    } 

    uint256 public constant INTEREST_RATE = 5; // 5% per year
    uint256 public constant SECONDS_IN_YEAR = 365 days;
    uint256 public constant LTV = 70; // 70%
    uint256 public constant LOAN_INTEREST_RATE = 8; // 8% per year 

    mapping(address => Account ) private accounts;
    mapping(address => Loan) private loans;

    bool private locked; 

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    event DepositEth(address indexed user, uint256 amount);
    event WithdrawEth(address indexed user, uint256 amount);


    // ---- ACCOUNT ----

    // Deposit ETH
    function depositEth() external payable {
        require(msg.value > 0, "Must send ETH");

        _updateBalance(msg.sender);

        accounts[msg.sender].balance += msg.value;
        accounts[msg.sender].lastUpdate = block.timestamp;

        emit DepositEth(msg.sender, msg.value);
    }

    // Withdraw ETH
    function withdrawEth(uint256 amount) external {
        _updateBalance(msg.sender);

        require(accounts[msg.sender].balance >= amount, "Insufficient balance");

        // Effects
        accounts[msg.sender].balance -= amount;

        // Interaction
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit WithdrawEth(msg.sender, amount); 
    }

    // Check balance
    function getBalance(address user) external view returns (uint256) {
        Account memory acc = accounts[user];

        uint256 interest = _calculateInterest(user);

        return acc.balance + interest;
    }



    // ---- INTEREST ----

    // Calculate acumulate interest
    function _calculateInterest(address user) internal view returns (uint256) {
        Account memory account = accounts[user];

        if (account.balance == 0) return 0;

        uint256 timeElapsed = block.timestamp - account.lastUpdate;

        uint256 interest = (account.balance * INTEREST_RATE * timeElapsed) / (100 * SECONDS_IN_YEAR);

        return interest;
    }

    // Update balance with interest
    function _updateBalance(address user) internal {
        uint256 interest = _calculateInterest(user);

        accounts[user].balance += interest;
        accounts[user].lastUpdate = block.timestamp;
    }



    // ---- LOANS ----

    // Calculate debt with interest
    function _calculateLoanInterest(address user) internal view returns (uint256) {
        Loan memory loan = loans[user];

        if (loan.amount == 0) return 0;

        uint256 timeElapsed = block.timestamp - loan.lastUpdate;

        uint256 interest = (loan.amount * LOAN_INTEREST_RATE * timeElapsed) / (100 * SECONDS_IN_YEAR);

        return interest;
    } 

    // Update loan
    function _updateLoan(address user) internal {
        uint256 interest = _calculateLoanInterest(user);

        loans[user].amount += interest;
        loans[user].lastUpdate = block.timestamp;
    }

    // Borrow
    function borrow(uint256 amount) external nonReentrant {
        _updateBalance(msg.sender);
        _updateLoan(msg.sender);

        uint256 collateral = accounts[msg.sender].balance;
        uint256 maxBorrow = (collateral * LTV) / 100;

        require(loans[msg.sender].amount + amount <= maxBorrow, "Exceeds LTV");


        loans[msg.sender].amount += amount;
        loans[msg.sender].lastUpdate = block.timestamp;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    // Repay loan
    function repayLoan() external payable nonReentrant {
        require(msg.value > 0, "Must repay something");

        _updateLoan(msg.sender);

        uint256 debt = loans[msg.sender].amount;

        if (msg.value >= debt) {
            loans[msg.sender].amount = 0;
        } else {
            loans[msg.sender].amount -= msg.value; 
        }

        loans[msg.sender].lastUpdate = block.timestamp;
    }

    // Check debt
    function getDebt(address user) external view returns (uint256) {
        Loan memory loan = loans[user];

        uint256 interest = _calculateLoanInterest(user);

        return loan.amount + interest;
    }
}