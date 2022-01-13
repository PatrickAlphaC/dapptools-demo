# DappTools Demo
- [DappTools Demo](#dapptools-demo)
  - [Intro](#intro)
- [QuickStart](#quickstart)
  - [Setup](#setup)
- [Build it from scratch](#build-it-from-scratch)
  - [Install Dapptools](#install-dapptools)
  - [Create a new dapptools project](#create-a-new-dapptools-project)
  - [Run Tests](#run-tests)
  - [Fuzzing](#fuzzing)
  - [Importing from Openzeppelin or external contracts](#importing-from-openzeppelin-or-external-contracts)
    - [The NFT Contract](#the-nft-contract)
    - [Remappings](#remappings)
  - [Deploying to a testnet](#deploying-to-a-testnet)
    - [Interacting with contracts](#interacting-with-contracts)
  - [Verify your contract on Etherscan](#verify-your-contract-on-etherscan)
  - [And finally...](#and-finally)
- [Resources](#resources)


## Intro 

For a more full repo with more good code and examples, checkout the [dapptools-starter-kit](https://github.com/smartcontractkit/dapptools-starter-kit).

You can work with this repo one of two ways. 
1. [Just copy it](#quickstart) (git clone it), and go from there
2. [Build it from scratch yourself](#build-it-from-scratch)

We will teach both.

# QuickStart

## Setup 

1. [Install Dapptools](#install-dapptools) and [git](https://git-scm.com/downloads)

Also see the [official instructions](https://github.com/dapphub/dapptools). 

2. Clone this repo 

```
git clone 
cd dapptools-demo 
make # This installs the project's dependencies.
```

3. Run tests 

```
dapp test 
```


# Build it from scratch 

We will show you how to make this exact repo from nothing. 

## Install Dapptools

To make sure you're using the most up-to-date install method, be sure to read the [dapptools](https://github.com/dapphub/dapptools) repo. 

These instructions only work for Unix based systems (For example, MacOS, Linux). For windows users, please check out [WSL](https://docs.microsoft.com/en-us/windows/wsl/install) to run linux commands on your windows. 

0. Instsall git

You'll need to install [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) if you haven't already. You can run the `git --version` command to see if it's already installed, and it should print something like: `git version 2.32.0`

1. Install Nix

```bash
# user must be in sudoers
curl -L https://nixos.org/nix/install | sh

# Run this or login again to use Nix
. "$HOME/.nix-profile/etc/profile.d/nix.sh"
```

2. Install `dapptools`:

```bash 
curl https://dapp.tools/install | sh
```
This configures the dapphub binary cache and installs the `dapp`, `solc`, `ethsign`, `seth` and `hevm` executables.

## Create a new dapptools project

```bash 
dapp init
```

This will give you a basic file layout that should look like this:

```
.
├── Makefile
├── lib
│   └── ds-test
│       ├── LICENSE
│       ├── Makefile
│       ├── default.nix
│       ├── demo
│       │   └── demo.sol
│       └── src
│           └── test.sol
├── out
│   └── dapp.sol.json
└── src
    ├── DapptoolsDemo.sol
    └── DapptoolsDemo.t.sol
```

`Makefile`: Where you put your "scripts". Dapptools is command line based, and our makefile helps us run large commands with a few characters. 

`lib`: This folder is for external dependencies, like [Openzeppelin](https://openzeppelin.com/contracts/) or [ds-test](https://github.com/dapphub/ds-test). 

`out`: Where your compiled code goes. Similar to the `build` folder in `brownie` or the `artifacts` folder in `hardhat`. 

`src`: This is where your smart contracts are. Similar to the `contracts` folder in `brownie` and `hardhat`. 


## Run Tests

```
dapp test
```
and you'll see an output like:

```
Running 2 tests for src/DapptoolsDemo.t.sol:DapptoolsDemoTest
[PASS] test_basic_sanity() (gas: 190)
[PASS] testFail_basic_sanity() (gas: 2355)
```

## Fuzzing 

Dapptools comes built in with an emphasis on [fuzzing](https://en.wikipedia.org/wiki/Fuzzing). An incredibly powerful tool for testing our contracts with random data. 

Let's update our `DapptoolsDemo.sol` with a function called `play`. Here is what our new file should look like:

```javascript
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

contract DapptoolsDemo {

    function play(uint8 password) public pure returns(bool){
        if(password == 55){
            return false;
        }
        return true;
    }
}
```

And we will add a new test in our `DappToolsDemo.t.sol` that is fuzzing compatible called `test_basic_fuzzing`. The file will then look like this: 

```javascript 
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./DapptoolsDemo.sol";

contract DapptoolsDemoTest is DSTest {
    DapptoolsDemo demo;

    function setUp() public {
        demo = new DapptoolsDemo();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }

    function test_basic_fuzzing(uint8 value) public {
        bool response = demo.play(value);
        assertTrue(response);
    }
}
``` 

We can now give our contract random data, and we will expect it to error out if our code gives it the number `55`. Let's run our tests now with the fuzzing flag: 
```bash 
dapp test --fuzz-runs 1000
``` 
And we will see an output like: 

```bash 
Running 3 tests for src/DapptoolsDemo.t.sol:DapptoolsDemoTest
[PASS] test_basic_sanity() (gas: 190)
[PASS] testFail_basic_sanity() (gas: 2355)
[FAIL] test_basic_fuzzing(uint8). Counterexample: (55)
Run:
 dapp test --replay '("test_basic_fuzzing(uint8)","0x0000000000000000000000000000000000000000000000000000000000000037")'
to test this case again, or 
 dapp debug --replay '("test_basic_fuzzing(uint8)","0x0000000000000000000000000000000000000000000000000000000000000037")'
to debug it.

Failure: 
  
  Error: Assertion Failed
```

And our fuzzing tests picked up the outlier!

## Importing from Openzeppelin or external contracts  

Let's say we want to create an NFT using the Openzeppelin standard. To install external contracts or packages, we can use the `dapp install` command. We need to name the github repo organization and the repo name to install. 

First, we need to commit our changes so far! dapptools brings external packages in as [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), so we need to commit first. 

Run: 

```bash 
git add .
git commit -m 'initial commit'
```

Then, we can install our external packages. For example, for https://github.com/OpenZeppelin/openzeppelin-contracts, we'd use: 

```bash 
dapp install OpenZeppelin/openzeppelin-contracts
```

You should see a new folder in your `lib` folder now labeled `openzeppelin-contracts`.

### The NFT Contract 

Create a new file in the `src` folder called `NFT.sol`. And add this code:

```javascript 
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    uint256 public tokenCounter;
    constructor () ERC721 ("NFT", "NFT"){
        tokenCounter = 0;
    }

    function createCollectible() public returns (uint256) {
        uint256 newItemId = tokenCounter;
        _safeMint(msg.sender, newItemId);
        tokenCounter = tokenCounter + 1;
        return newItemId;
    }
}
``` 
If you try to `dapp build` now, you'll get a big error! 

### Remappings

We need to tell dapptools that `import "@openzeppelin/contracts/token/ERC721/ERC721.sol";` is pointing to our `lib` folder. So we make a file called `remappings.txt` and add:

```
@openzeppelin/=lib/openzeppelin-contracts/
ds-test/=lib/ds-test/src/
```

Then, we make a file called `.dapprc` and add the following line: 

```bash
export DAPP_REMAPPINGS=$(cat remappings.txt)
```

Dapptools looks into our `.dapprc` for different configurtion variables, sort of like `hardhat.config.js` in `hardhat`. In this configuration file, we tell it to read the output of `remappings.txt` and use those as "remappings". Remappings are how we tell our imports in solidity where we should import the files from. For example in our `remapping.txt` we see:

```
@openzeppelin/=lib/openzeppelin-contracts/
```

This means we are telling dapptools that when it compiles a file, and it sees `@openzeppelin/` in an import statement, it should look for files in `lib/openzeppelin-contracts/`. So if we do 

```
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
```

We are really saying:

```
import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
```

Then, so that we don't compile the whole library, we need to add the following to our `.dapprc` file:

```
export DAPP_LINK_TEST_LIBRARIES=0
```

This tells dapptools to not compile everything in `lib` when we run tests. 
 

## Deploying to a testnet 

> Note: If you want to setup your own local network, you can run `dapp testnet`.

0. Add `.env` to your `.gitignore` file. 

Please do this. 

1. Set an `ETH_RPC_URL` environment variable

Create a file called `.env`. Then, add the http endpoint for you blockchain of choice to an environment variable named `ETH_RPC_URL`. You can get a free 3rd party http endpoint from [Alchemy](https://alchemy.com/?a=673c802981).

If you're new to networks, I'd recommend getting a kovan ETH http endpoint. 

For example, your `.env` might look like:

```
export ETH_RPC_URL=http://alchemy.io/adfsasdfasdf
```
 
2. Create a default sender 

Get an [eth wallet](https://metamask.io/) if you haven't already. You can [see some instructions here](https://docs.chain.link/docs/deploy-your-first-contract/#install-and-fund-your-metamask-wallet). 

Once you have a wallet, set the address of that wallet as a `ETH_FROM` environment variable. 

```
export ETH_FROM=YOUR_DEFAULT_SENDER_ACCOUNT
```

Additionally, if using Kovan, [fund your wallet with testnet ETH](https://faucets.chain.link/). 

3. Add your private key 

> NOTE: I HIGHLY RECOMMEND USING A METAMASK THAT DOESNT HAVE ANY REAL MONEY IN IT FOR DEVELOPMENT. 
> If you push your private key to github with real money in it, people can steal your funds. 

Dapptools comes with a tool called `ethsign`, and this is where we are going to store and encrypt our key. To add our private key (needed to send transactions) get the private key of your wallet, and run:

```
ethsign import 
``` 

Then add your private key, and a password to encrypt it. This encrypts your private key in `ethsign`. You'll need your password anytime you want to send a transaction moving forward. 

4. Update our `Makefile` 

The command we can use to deploy our contracts is `dapp create DapptoolsDemo` and then some flags to add in environment variables. To make our lives easier, we can add our deploy command to a Makefile, and just tell the Makefile to use our environment variables. 

Add the following to our `Makefile` 

```
-include .env
```

5. Deploy the contract! 

In our `Makefile`, we have a command called `deploy`, this will run `dapp create DapptoolsDemo` and include our environment variables. To run it, just run:

```
make deploy
```

And you'll be prompted for you password. After, it'll deploy your contract! 

``` 
dapp create DapptoolsDemo
++ seth send --create 608060405234801561001057600080fd5b50610158806100206000396000f3fe608060405234801561001057600080fd5b506004361061002b5760003560e01c806353a04b0514610030575b600080fd5b61004a60048036038101906100459190610096565b610060565b60405161005791906100d2565b60405180910390f35b600060378260ff161415610077576000905061007c565b600190505b919050565b6000813590506100908161010b565b92915050565b6000602082840312156100ac576100ab610106565b5b60006100ba84828501610081565b91505092915050565b6100cc816100ed565b82525050565b60006020820190506100e760008301846100c3565b92915050565b60008115159050919050565b600060ff82169050919050565b600080fd5b610114816100f9565b811461011f57600080fd5b5056fea2646970667358221220b1f0848a7865f42db510abbc5322e1c1bdcdcdc59100106a5b1e01590f92655464736f6c63430008060033 'DapptoolsDemo()'
seth-send: warning: `ETH_GAS' not set; using default gas amount
Ethereum account passphrase (not echoed): seth-send: Published transaction with 376 bytes of calldata.
seth-send: 0xa91d9ee86311eea260e1999b537fc05a941988fc28da63982d00d755904cd902
seth-send: Waiting for transaction receipt..........
seth-send: Transaction included in block 29244645.
0xf8bEca9A4CC470d72387E03B801f36623141A4C5
```

And you can see it on Etherscan. 

### Interacting with contracts 

To interact with deployed contracts, we can use `seth call` and `seth send`. 

To *read* data from the blockchain, we could do something like:

```
ETH_RPC_URL=<YOUR_RPC_URL> seth call <YOUR_DEPLOYED_CONTRACT> "FUNCTION_NAME()" <ARGUMENTS_SEPARATED_BY_SPACE>
```

Like:

```
ETH_RPC_URL=<YOUR_RPC_URL> seth call 0x12345 "play(uint8)" 55
```

To which you'll get `0x0000000000000000000000000000000000000000000000000000000000000000` which means false. 

To *write* data to the blockchain, we could do something like:

```
ETH_RPC_URL=<YOUR_RPC_URL> ETH_FROM=<YOUR_FROM_ADDRESS> seth send <YOUR_DEPLOYED_CONTRACT> "FUNCTION_NAME()" <ARGUMENTS_SEPARATED_BY_SPACE>
```


## Verify your contract on Etherscan

After you've deployed a contract to etherscan, you can verify it by:

1. Getting an [Etherscan API Key](https://etherscan.io/apis). 

2. Then running 


```
ETHERSCAN_API_KEY=<api-key> dapp verify-contract <contract_directory>/<contract>:<contract_name> <contract_address>
```

For example:

```
ETHERSCAN_API_KEY=123456765 dapp verify-contract ./src/DapptoolsDemo.sol:DapptoolsDemo 0x23456534212536435424
```

## And finally...

1. Add `cache` to your `.gitignore` 
2. Add `update:; dapp update` to your `Makefile`
   1. This will update and download the files in `.gitmodules` and `lib`
3. Add a LICENSE 
   1. You can just copy this one if you don't know how!

And you're done!

# Resources

If you liked this, consider donating! 
💸 ETH Wallet address: 0x9680201d9c93d65a3603d2088d125e955c73BD65

* [DappTools](https://dapp.tools)
    * [Hevm Docs](https://github.com/dapphub/dapptools/blob/master/src/hevm/README.md)
    * [Dapp Docs](https://github.com/dapphub/dapptools/tree/master/src/dapp/README.md)
    * [Seth Docs](https://github.com/dapphub/dapptools/tree/master/src/seth/README.md)
* [DappTools Overview](https://www.youtube.com/watch?v=lPinWgaNceM)
* [Chainlink](https://docs.chain.link)



