# Sample Hardhat Project

# jointBankAccountContract
To create a sample specification for a joint bank account smart contract, we can refer to the information available in the search results. Here's a sample specification based on the available snippets:

#### Specification for Joint Bank Account Smart Contract

The joint bank account smart contract will allow multiple users to create and manage a shared bank account. The contract will include the following functionalities:

1. **Account Creation**
   - Users should be able to create a joint bank account by providing their addresses as input.
   - The contract should check whether the user addresses provided already exist in the contract.
   - If the account already exists, the contract should prevent the creation of a duplicate account.
   - The contract should also enforce a minimum deposit requirement for account creation.

2. **Account Balance**
   - Users should be able to check the balance of the joint bank account.
   - Access to the account balance should be restricted to users who have an account.

3. **Deposits**
   - Users should be able to deposit funds into the joint bank account.
   - The contract should ensure that a user cannot deposit more funds than their balance allows.
   - Funds deposited by users should be added to the joint bank account balance.

4. **Withdrawals**
   - Users should be able to withdraw funds from the joint bank account.
   - only account owner can approve and request withdrawal
   - The contract should prevent users from withdrawing more funds than their balance allows.
   - When a user makes a withdrawal, the contract should deduct the amount from the user's balance and transfer it to their address.




Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```
