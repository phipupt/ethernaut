# ethernaut

## level 3

[The Ethernaut level 3](https://ethernaut.openzeppelin.com/level/0xA62fE5344FE62AdC1F356447B669E9E6D10abaaF)

这一关的要求是在一次投币游戏中通过猜测投币的结果连续正确10次。

为了在连续猜对10次，必须预测 `blockValue`，并在调用 `flip` 函数时提供正确的 `_guess` 参数。

基于以上的分析，可以设计如下步骤来连续正确猜测10次：

1. 部署一个新的合约(`Attacker`)，该合约能够计算并预测 `CoinFlip` 合约的投币结果。
2. 使用该合约调用 `CoinFlip` 合约的 `flip` 函数，这样每次都能提供正确的 `_guess` 参数。
3. 重复调用多次

示例合约在[这里](ethernaut/script/Level03.s.sol)

链上记录：
- level(`CoinFlip`) 新实例：https://sepolia.etherscan.io/address/0x7ECf6bB565c69ccfac8F5d4b3D785AB78a00F677
- attacker 合约：https://sepolia.etherscan.io/address/0xdce3c80980837bfb66524bc0ccf3d2f5db5ae8ff



## level 4

[The Ethernaut level 4](https://ethernaut.openzeppelin.com/level/0x2C2307bb8824a0AbBf2CC7D76d8e63374D2f8446)

这一关的要求是获得合约的owner权限。

要获得owner权限，需要调用 `changeOwner` 方法，但条件是 `tx.origin != msg.sender`。

这个条件可以通过使用一个中间合约来绕过，通过中间合约去调用目标合约来实现。此时
- `tx.origin` = 发送交易者
- `msg.sender` = 中间合约地址

示例合约在[这里](Writeup/phipupt/ethernaut/script/Level04.s.sol)

链上记录：
- level(`Telephone`) 新实例：0x231014b0FEf1C0AF96189700a43221fACF1DfF7E
- attacker 合约：https://sepolia.etherscan.io/address/0xa380337b31833736daa3a044a41e5fb821d15128
- 可以使用 `cast call` 命令来调用目标合约的 `owner` 函数来获取 `owner` 地址。：
`cast call 0x231014b0FEf1C0AF96189700a43221fACF1DfF7E "owner()(address)" --rpc-url sepolia`


## level 5

[The Ethernaut level 5](https://ethernaut.openzeppelin.com/level/0x478f3476358Eb166Cb7adE4666d04fbdDB56C407)

这一关要求获得更多的token。

合约看起来没什么问题，但是 solidity 版本用的是是 0.6，没有处理整型的下溢/溢出。

因此，只需要发送大于 20 的值，比如 21，就可以获得 21 个token

直接使用 Foundry 的命令: 

查询余额：

```
cast call <level address> \
"balanceOf(address)(uint256)" <receiver> \
--rpc-url sepolia
```

转账（获取更多token）
```
cast send <level address> \
"transfer(address,uint256)(bool)" <receiver> 21 \
--rpc-url sepolia \
--private-key <deployer private key> 
```

链上记录：
- level(`Token`) 新实例：[0xC8622C44a00a6d01a0c63390eD54E111ef56282f](https://sepolia.etherscan.io/address/0xC8622C44a00a6d01a0c63390eD54E111ef56282f)
- receiver: 0x5859FdBE15be13b4413F0E5F96Ce27364F6E21C8


## level 6

[The Ethernaut level 6](https://ethernaut.openzeppelin.com/level/0x73379d8B82Fda494ee59555f333DF7D44483fD58)

这一关要求获得 `Delegation` 合约的 `owner` 权限

要获取 `Delegation` 合约中的 `owner` 权限，关键在于利用 `Delegation` 合约的 `fallback` 函数和 `delegatecall` 的特性。`delegatecall` 会在调用合约的上下文中执行被调用的代码，这意味着它会使用调用合约的存储。

步骤如下：
1. 计算 `Delegate` 合约中 `pwn()` 函数的函数选择器

    `pwn() `函数的选择器是其函数签名的 `keccak256` 哈希的前 4 个字节。

2. 向 `Delegation` 合约发送一个调用，其中：

    `msg.data` 应该是 `pwn()` 函数的选择器。

    可以使用任何数量的 ETH。

3. 这将触发 `Delegation` 合约的 `fallback` 函数，进而使用 `delegatecall` 调用 `Delegate` 合约的 `pwn()` 函数。
4. 由于使用了 `delegatecall`，`pwn()` 函数将在 `Delegation` 合约的上下文中执行，从而将调用者的地址设置为 `Delegation` 合约的 `owner。`

使用 Foundry cast 命令可以更简单：

调用 `Delegation` 合约 `pwn()` 函数
```
cast send <level address> \
"pwn()()" \
--rpc-url sepolia \
--private-key <your private key> 
```

查询当前 `owner`
```
cast call <level address> \
"owner()(address)" \
--rpc-url sepolia
```

链上记录：
- level(`Delegation`) 新实例：[0xA54C5bFcdd15Cb9D38485741C5b304a20E269eB5](https://sepolia.etherscan.io/address/0xA54C5bFcdd15Cb9D38485741C5b304a20E269eB5)
- 获取权限的交易的哈希: [0xa74c34ac10570535f2faa6b86677a3a2c5799783fac5bfe874c3cbbf9d27c3b2](https://sepolia.etherscan.io/tx/0xa74c34ac10570535f2faa6b86677a3a2c5799783fac5bfe874c3cbbf9d27c3b2)


## lelve 7

[The Ethernaut level 7](https://ethernaut.openzeppelin.com/level/0xb6c2Ec883DaAac76D8922519E63f875c2ec65575)

这一关的要求是增加 `Forece` 合约的 ether 余额

`Force` 合约没有任何函数，要想向该合约发送 ether，普通转账是不行的。需要使用一些特殊的方法。以下是几种可能的方式：
1. 自毁方法（`selfdestruct`）：这是最常见的强制发送以太币到一个没有接收函数的合约的方法。
2. 预部署合约：使用 `CREATE2` 操作码预先计算出合约的地址，并在合约部署之前向该地址发送 ether。

由于合约不是自己部署，因此采用第一种方式。

示例代码：
```
contract Attacker {
    constructor() {}

    function attack(address receiver) public payable {
        selfdestruct(payable(receiver));
    }

    receive() external payable {}
}
```
完整代码见：[Attacker](ethernaut/script/level07/Attacker.s.sol)

使用Foundry：

调用脚本部署 `Attacker` 合约并且发动 `attack`：
```
forge script script/level07/Attacker.s.sol:CallContractScript --rpc-url sepolia --broadcast

```

查询 ether 余额
```
cast balance 0xd2E4Ba00684F3d61D585ca344ec566e03FA06F47 --rpc-url sepolia
```

链上记录：
- [level(`Force`) 实例](https://sepolia.etherscan.io/address/0xd2E4Ba00684F3d61D585ca344ec566e03FA06F47)
- [自毁并发送 ether 交易](https://sepolia.etherscan.io/tx/0xbc33047553c932bba41adb3e45c83940e7a5c5df4343a08121851c3bee357a7c)