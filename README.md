# ethernaut

## level 3
这个挑战要求在一次投币游戏中通过猜测投币的结果连续正确10次。

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

Ethernaut的第4关要求获得合约的owner权限。

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
The Ethernaut level 5

第 5 关要求获得更多的token。

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