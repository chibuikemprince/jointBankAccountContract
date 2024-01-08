/*
SPDX-License-Identifier: MIT
*/
pragma solidity >=0.4.22 <=0.8.19;

contract BankAccount {

address public owner;
constructor(){
owner = msg.sender;
}
event Deposit ( 
    address indexed user,
    uint256 indexed accountId,
    uint256 value,
    uint256 timestamp

);

    
event WithdrawalRequest ( 
    address indexed user,
    uint256 indexed accountId,
    uint256 indexed withdrawalId,
    uint256 amount,
    uint256 timestamp

);

error MaxAccoutExceeded(string msg);

event Withdraw(uint256 indexed withdrawalId, uint256 timestamp) ;
event AccountCreated(address[]  owners, uint256 id, uint256 timestamp);

struct WithdrawRequests{

    address user;
    uint amount;
    uint approvals;
    mapping( address => bool) ownersApproved;
    bool approved; 

}

struct Account{
    address[] owners;
    uint balance;
    mapping(uint=> WithdrawRequests) withdrawRequests;
}

mapping (uint=> Account)  accounts;
mapping(address => uint[]) userAccounts;



uint newAccountId;
uint newWithdrawId;

modifier accountOwner(uint accountId){
bool isOwner = false;
for(uint idx; idx< accounts[accountId].owners.length; idx++ ){
    if(accounts[accountId].owners[idx] == msg.sender ){
isOwner = true;
    }

 require(isOwner == true, "you are not an owner of this account");   
}
    _;
}


modifier validOwners(address[] calldata owners){
    require(owners.length +1 <= 4, "maximum of 4 owners per account");
    // check for duplicates
    for(uint idx; idx< owners.length; idx++) {

  if(owners[idx] ==  msg.sender){
                revert("No duplicate owners");
            }

        for(uint jdx; jdx< idx; jdx++){
            if(owners[idx] == owners[jdx]){
                revert("No duplicate owners");
            }
        }
    }
    _;
}


modifier sufficientBalance(uint accountId, uint amount){
  require(  accounts[accountId].balance >= amount, "insufficient balance");
  _;
}

modifier canApprove(uint accountId, uint withdrawId){

    require(accounts[accountId].withdrawRequests[withdrawId].approved, "request has been approved");
    require(accounts[accountId].withdrawRequests[withdrawId].user != msg.sender, "you can't approve your own request");
    require(accounts[accountId].withdrawRequests[withdrawId].user != address(0), "request doent exist");
    require(accounts[accountId].withdrawRequests[withdrawId].ownersApproved[msg.sender] != true, "you have approved this request");

_;

}

modifier canwithdraw(uint accountId, uint withdrawId){

     require(accounts[accountId].withdrawRequests[withdrawId].user == msg.sender, "you can't withdraw amount not in your own request");
   require(accounts[accountId].withdrawRequests[withdrawId].approved, "request has been approved");
   
_;

}
function deposit(uint acountId) accountOwner(acountId) external payable{

    accounts[acountId].balance += msg.value;
}

function createAccount(address[] calldata otherOwners) external validOwners(otherOwners){
address[] memory owners = new address[](otherOwners.length+1);
//uint[] memory acc = new uint[](3);
owners[otherOwners.length] = msg.sender;

for(uint idx; idx<owners.length; idx++){
if(idx< owners.length-1){
    owners[idx] = otherOwners[idx];
    if(otherOwners[idx] == msg.sender){

        revert( "you cannot be an owner of your own account");

    }
}
if(userAccounts[owners[idx]].length >2){
revert MaxAccoutExceeded(" each user cannot have more than 3 accounts" );

}
 userAccounts[owners[idx]].push(newAccountId); 
// instead of changing value in the storage multiple times,
// use a memory array instead and change value in the storage just once.

//acc.push(newAccountId);

}

//userAccounts[owners[idx]] = acc;
accounts[newAccountId].owners = owners;
newAccountId ++;
emit AccountCreated(owners, newAccountId, block.timestamp); 

}
function requestWithdrawal(uint accountId, uint amount) external 
accountOwner(accountId)
sufficientBalance(  accountId,   amount)
{

WithdrawRequests storage request = accounts[accountId].withdrawRequests[newWithdrawId];
request.user = msg.sender;
request.amount = amount;
request.approvals = 0;
request.approved = false;


emit WithdrawalRequest(msg.sender, accountId, newWithdrawId, amount, block.timestamp);
newWithdrawId++;

}


function approveWIthdrawal(uint accountId, uint withdrwalId) 
external
accountOwner(accountId)
canApprove(accountId, withdrwalId)
//sufficientBalance( accountId,   amount)
{

WithdrawRequests storage request = accounts[accountId].withdrawRequests[withdrwalId];
request.approvals++;
request.ownersApproved[msg.sender] = true;


if(request.approvals == accounts[accountId].owners.length-1){
    request.approved = true;
}

 }


function withdraw (uint accountId, uint withdrwalId) external
canwithdraw(accountId, withdrwalId)
{ 

uint amount =  accounts[accountId].withdrawRequests[withdrwalId].amount;
require(accounts[accountId].balance >= amount, " insufficient balance");
accounts[accountId].balance -= amount;
address user = accounts[accountId].withdrawRequests[withdrwalId].user;
delete accounts[accountId].withdrawRequests[withdrwalId];
(bool sent,) = payable(user).call{value:amount}("");
require(sent==true, "withdrawal failed");
}

function getBalance(uint accountId) public view returns(uint){
    return accounts[accountId].balance;
}

function getOwners(uint accountId) public view returns(address[] memory){ 
    return accounts[accountId].owners;
}

function getApprovals(uint accountId, uint withdrawId) public view returns(uint)
 {

    return accounts[accountId].withdrawRequests[withdrawId].approvals;
 }


function getAccounts() public view returns(uint[] memory) {
    return userAccounts[msg.sender];
}




}