<!DOCTYPE html>
<html>
<head>
<style>
    .full-page {
        width:  100%;
        height:  100vh; /* This will make the div take up the full viewport height */
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }
    .full-page img {
        max-width:  200;
        max-height:  200;
        margin-bottom: 5rem;
    }
    .full-page div{
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }
</style>
</head>
<body>

<div class="full-page">
    <img src="./logo.svg" alt="Logo">
    <div>
    <h1>Protocol Audit Report</h1>
    <h3>Prepared by: juaaanmac</h3>
    </div>
</div>

</body>
</html>

<!-- Your report starts here! -->

# Table of Contents
- [Table of Contents](#table-of-contents)
- [Protocol Summary](#protocol-summary)
- [Disclaimer](#disclaimer)
- [Risk Classification](#risk-classification)
- [Audit Details](#audit-details)
  - [Scope](#scope)
  - [Roles](#roles)
- [Executive Summary](#executive-summary)
  - [Issues found](#issues-found)
- [Findings](#findings)
- [High](#high)
- [Medium](#medium)
- [Low](#low)
- [Informational](#informational)
- [Gas](#gas)

# Protocol Summary

Protocol allows you to collect funds and withdraw them when you want

# Disclaimer

The juaaanmac team makes all effort to find as many vulnerabilities in the code in the given time period, but holds no responsibilities for the findings provided in this document. A security audit by the team is not an endorsement of the underlying business or product. The audit was time-boxed and the review of the code was solely on the security aspects of the Solidity implementation of the contracts.

# Risk Classification

|            |        | Impact |        |     |
| ---------- | ------ | ------ | ------ | --- |
|            |        | High   | Medium | Low |
|            | High   | H      | H/M    | M   |
| Likelihood | Medium | H/M    | M      | M/L |
|            | Low    | M      | M/L    | L   |

We use the [CodeHawks](https://docs.codehawks.com/hawks-auditors/how-to-evaluate-a-finding-severity) severity matrix to determine severity. See the documentation for more details.

# Audit Details 
**The findings described in this document correspond the following commit hash:**
```
xxxxxxxxxxxx
```

## Scope 
```
src/
--- Fundraising.sol
```

## Roles

- Owner: user who want to collect funds and the only one who should withdraw funds.
- Contributors: users who contribute their funds to the fundraising.

# Executive Summary
## Issues found
| Severity          | Number of issues found |
| ----------------- | ---------------------- |
| High              | 1                      |
| Medium            | 1                      |
| Low               | 0                      |
| Info              | 0                      |
| Gas Optimizations | 2                      |
| Total             | 4                      |

# Findings

# High

### [H-1] `Fundraising::withdraw` is vulnerable to a reentrancy attack, an untrusted attacker’s contract can drain the contract’s fund.

**Description**
A reentrancy attack happens when a function is externally invoked during its execution, allowing it to be run multiple times in a single transaction. This typically occurs when a contract calls another contract before it resolves its state.
If an untrusted attacker’s contract contribute to the Fundraising and then call withdraw `Fundraising::withdraw`, it will be able to drain the contract’s fund.

**Impact**
An untrusted attacker’s contract can drain the contract’s fund.

**Proof of Concepts**
Apply https://solidity-by-example.org/hacks/re-entrancy/

**Recommended mitigation**
Add a reentrancy guard or use the “Checks-Effects-Interactions” Pattern.

# Medium

### [M-1] Function `Fundraising::setTitle` is callable by anyone, so any user can change the fundraising title.

**Description:** The `Fundraising::setTitle` function is set to be an `external` function, however the natspec of the function is `This function allows the owner to modify the title`, that is, only the owner should modify it.

**Impact**
Anyone can set/change the password of the contract.

**Proof of Concept:** 

Add the following to the `Fundraising.t.sol` test suite.

```javascript
function test_anyone_can_set_title(address randomAddress) public {
    vm.prank(randomAddress);
    string memory expectedTitle = "newTitle";
    fundraising.setTitle(expectedTitle);
    vm.prank(owner);
    string memory actualTitle = fundraising.getTitle();
    assertEq(expectedTitle, actualTitle);
}
```

**Recommended Mitigation:** Add an access control modifier to the `setTitle` function. You can you `Fundraising::onlyOwner` modifier.

# Gas 

### [G-1] Data location `memory` instead of `calldata` for parameter `title_` in function `Fundraising::setTitle` increases gas-cost

**Description:** `memory` is used to hold temporary variables during function execution, while `calldata` is used to hold function arguments passed in from an external caller. Calldata is read-only and cannot be modified by the function, while Memory can be modified. The parameter `title_` in `Fundraising::setTitle` is not modified. so you can use `calldata` to save gas.

**Impact**
Data location `memory` increase gas-cost.

**Proof of Concept:** 

In a new terminal, run:

```
forge test --gas-report
```

Change data location for `title_` in `Fundraising::setTitle` to `calldata`

```javascript
function setTitle(string calldata title_) external{
    title = title_;
}
```

Run again:

```
forge test --gas-report
```

Compare the previous report with the last one

**Recommended Mitigation:** Change data location for `title_` in `Fundraising::setTitle` to `calldata`.

### [G-2] The order of the state variables of `Fundraising` is not optimal, resulting in an increase in gas-cost 

**Description:** When you define the state variables for your contract, you can store more information in the same amount of storage space, reducing the amount of gas required for deployment. To achieve tight variable packing, you need to pay attention to the order and size of your variables. For example, larger variables should be placed before smaller ones.

**Impact**
The order of the state variables in `Fundraising` increase gas-cost.

**Proof of Concept:** 

In a terminal, run:

```
anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1
```

In a new terminal, run this command to deploy Fundrasing contract:

```javascript
forge script script/DeployFundraising.s.sol:Fundraising --rpc-url 'http://localhost:8545' --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```

Get the address of the deployed contract (for example 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0) and run:

```
cast storage 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
```

You will see that the contract requires 4 slots.

Now, change the order of the state variables as follows:

```javascript
    address owner;
    bool public finished;
    string public title;
    uint256 public amountCollected;
    mapping(address => uint256) public contributions;
```

Deploy the contract again

```javascript
forge script script/DeployFundraising.s.sol:Fundraising --rpc-url 'http://localhost:8545' --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
```

Get the address of the deployed contract (for example 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9) and run:

```
cast storage 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9
```
Now, the contract requires only 3 slots.

**Recommended Mitigation:** Apply Tight Variable Packing pattern, reordering the state variables `title` and `finished`:

```javascript
    address owner;
    bool public finished;
    string public title;
    uint256 public amountCollected;
    mapping(address => uint256) public contributions;
```

With this order, you only need 3 slots instead of 4.