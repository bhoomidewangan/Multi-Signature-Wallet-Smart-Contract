
# 🔐 MultiSig Wallet – Solidity Smart Contract

A **Multi-Signature (MultiSig) Wallet** implemented in Solidity that enhances transaction security by requiring multiple approvals before executing transfers. This smart contract mimics a real-world joint account setup and deepens your understanding of access control, smart contract flow, and transaction coordination.

---

## 📌 Table of Contents

- [Features](#features)
- [How It Works](#how-it-works)
- [Smart Contract Overview](#smart-contract-overview)
- [Usage Instructions](#usage-instructions)
- [Example Workflow](#example-workflow)
- [Deployment](#deployment)
- [Events](#events)
- [Learning Outcomes](#learning-outcomes)

---

## ✅ Features

- Multiple wallet owners
- Minimum confirmation threshold
- Submit, confirm, and execute transactions
- Protection against double confirmations and unauthorized actions
- Accepts and logs ETH deposits
- Events emitted for all major actions

---

## ⚙️ How It Works

The MultiSig wallet ensures that **no single owner** can unilaterally execute a transaction. The process requires:

1. **Transaction Submission**: Anyone can submit a transaction with ETH.
2. **Owner Confirmations**: Only listed owners can confirm it.
3. **Execution**: Once the number of confirmations reaches the required threshold, the transaction is executed.

This ensures **multi-party agreement** before transferring funds.

---

## 🧠 Smart Contract Overview

- **Solidity Version**: ^0.8.2
- **Owners**: Array of addresses initialized at deployment
- **Confirmations**: Mapped to track confirmations per transaction
- **Transaction Structure**:
  - `to`: Recipient address
  - `value`: Amount of ETH
  - `executed`: Flag to avoid re-execution

### 🔐 Key Modifiers

- `onlyOwner`: Restricts function to wallet owners
- `txExists`: Validates transaction existence
- `notExecuted`: Ensures transaction hasn't been executed
- `notConfirmed`: Prevents duplicate confirmations

---

## 🛠️ Usage Instructions

### 1. 📥 Deposit ETH

Send ETH to the contract using any of the following:

```solidity
receive() external payable {}
fallback() external payable {}
```

All deposits emit a `TransactionDeposit` event.

---

### 2. 📝 Submit a Transaction

```solidity
submitTransaction(address _to)
```

Call this function with `msg.value` in ETH.  
- `_to`: Address to which ETH should be sent.

> ✅ Anyone can submit a transaction.

---

### 3. ✅ Confirm a Transaction

```solidity
confirmTransaction(uint _transactionId)
```

- Only owners can confirm.
- Can’t confirm the same transaction twice.

---

### 4. 🚀 Execute a Transaction

Once enough confirmations are gathered, the transaction is automatically executed via:

```solidity
executeTransaction(uint _transactionId)
```

Can also be called manually by any user after threshold is met.

---

## 🔄 Example Workflow

1. Submit transaction with 0.5 ETH to `0xAbC...123`:
   ```solidity
   submitTransaction(0xAbC...123) payable
   ```

2. Owners confirm:
   ```solidity
   confirmTransaction(0)
   confirmTransaction(0)
   ```

3. Transaction is executed automatically or via:
   ```solidity
   executeTransaction(0)
   ```

---

## 🔊 Events

| Event | Description |
|-------|-------------|
| `TransactionDeposit(address sender, uint amount)` | ETH received |
| `TransactionSubmitted(uint id, address sender, address to, uint amount)` | Transaction created |
| `TransactionConfirmed(uint id)` | Transaction confirmed |
| `TransactionExecuted(uint id)` | Transaction executed |

---

## 🌐 Deployment

You can deploy this contract on:

- [Remix IDE](https://remix.ethereum.org/)
  - Use Injected Web3 with MetaMask and choose Goerli or Mumbai testnet
- [Hardhat](https://hardhat.org/) *(optional for testing & automation)*

---

## 🧠 Learning Outcomes

- Role-based access control using mappings and modifiers
- Secure multi-party logic implementation
- Use of structs and arrays in smart contracts
- Deployment and testing on Ethereum testnets

---
