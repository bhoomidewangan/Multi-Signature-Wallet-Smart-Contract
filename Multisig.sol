// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

// MultiSig Wallet
//A contract that requires multiple confirmations before executing a transaction.

contract MultiSig {

    address[] public owners; //array of address to store owners
    uint public numConfirmationsRequired; //minimum no of confirmations required to execute a transaction

    // Structure of a submitted transaction
    struct Transaction {
        address to;       // Recipient address
        uint value;       // Amount of Ether
        bool executed;    // Whether the transaction is executed
    }

    mapping(address => bool) public isOwner;   //mapping owner's address with boolean value 

    mapping(uint => mapping(address => bool)) public isConfirmed; //mapping transaction id with address of 

    Transaction[] public transactions; //array to record details of the transcation

    // Events for tracking key activities
    event TransactionDeposit(address indexed sender, uint amount);
    event TransactionSubmitted(uint transactionId, address sender, address reciever, uint amount);
    event TransactionConfirmed(uint transactionId);
    event TransactionExecuted(uint transactionId);

    // Restrict to only wallet owners
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    // Ensure the transaction exists
    modifier txExists(uint _transactionId) {
        require(_transactionId < transactions.length, "Transaction does not exist");
        _;
    }

    // Ensure the transaction has not been executed
    modifier notExecuted(uint _transactionId) {
        require(!transactions[_transactionId].executed, "Transaction already executed");
        _;
    }

    // Ensure the caller hasn't already confirmed the transaction
    modifier notConfirmed(uint _transactionId) {
        require(!isConfirmed[_transactionId][msg.sender], "Transaction already confirmed");
        _;
    }

    /**
     * @dev Constructor initializes the contract with owners and confirmation threshold
     * @param _owners Array of owner addresses
     * @param _numConfirmationsRequired Number of confirmations required for execution
     */
    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length > 0, "Owners required"); //no. of owners should be greater than 0
        require(
            _numConfirmationsRequired > 0 && _numConfirmationsRequired <= _owners.length,
            "Invalid number of confirmations"
        ); //no of confirmations required should be in sync with no of owners

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");  //owner address shouls not be invaild
            require(!isOwner[owner], "Owner not unique");   //owner should be unique

            isOwner[owner] = true;   //mapping owner address to true value
            owners.push(owner);   //adding owner to owner's list
        }

        numConfirmationsRequired = _numConfirmationsRequired;  //initializing no. of confirmations required
    }

    /**
     * @dev Receive Ether when sent without data (e.g., plain transfer)
     */
    receive() external payable {
        emit TransactionDeposit(msg.sender, msg.value);
    }

    /**
     * @dev Fallback function is triggered when no other function matches or when Ether is sent with data
     */
    fallback() external payable {
        emit TransactionDeposit(msg.sender, msg.value);
    }

    /**
     * @dev Submit a new transaction to be confirmed by owners
     * @param _to Recipient address
     */
    function submitTransaction(address _to) public payable {
        require(_to != address(0), "Invalid receiver's address");
        require(msg.value > 0, "Transfer amount must be greater than 0");

        uint transactionId = transactions.length;  //creating transaction id
        transactions.push(Transaction({
            to: _to,
            value: msg.value,
            executed: false
        }));  //recording transaction submission

        emit TransactionSubmitted(transactionId, msg.sender, _to, msg.value);
    }

    /**
     * @dev Allows an owner to confirm a transaction
     * @param _transactionId ID of the transaction to confirm
     */
    function confirmTransaction(uint _transactionId)
        public
        onlyOwner
        txExists(_transactionId)
        notConfirmed(_transactionId)
        notExecuted(_transactionId)
    {
        //setting ture value when transaction is confirmed by the caller
        isConfirmed[_transactionId][msg.sender] = true;   
        emit TransactionConfirmed(_transactionId);

        // Execute if enough confirmations are collected
        if (isTransactionConfirmed(_transactionId)) {
            executeTransaction(_transactionId);
        }
    }

    /**
     * @dev Execute a confirmed transaction
     * @param _transactionId ID of the transaction to execute
     */
    function executeTransaction(uint _transactionId)
        public
        payable
        notExecuted(_transactionId)
    {
        require(_transactionId < transactions.length, "Invalid transaction ID");
        require(!transactions[_transactionId].executed, "Transaction already executed");

        Transaction storage txn = transactions[_transactionId];

        // Send Ether using low-level call
        (bool success, ) = txn.to.call{value: txn.value}("");
        require(success, "Transaction execution failed");

        txn.executed = true;  //setting transaction executed to true
        emit TransactionExecuted(_transactionId);
    }

    /**
     * @dev Checks if a transaction has enough confirmations
     * @param _transactionId ID of the transaction to check
     * @return bool True if confirmed by enough owners
     */
    function isTransactionConfirmed(uint _transactionId) internal view returns (bool) {
        require(_transactionId < transactions.length, "Invalid transaction ID");

        //counting no. of confirmations for a transcation so that it should get executed 
        uint confirmationCount = 0;
     
        for (uint i = 0; i < owners.length; i++) {
            if (isConfirmed[_transactionId][owners[i]]) {
                confirmationCount++;
            }
        }

        return confirmationCount >= numConfirmationsRequired; //will return true if we have minimum no. of transcations 
    }
}

