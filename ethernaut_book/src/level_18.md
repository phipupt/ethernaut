# Level 18

[The Ethernaut level 18](https://ethernaut.openzeppelin.com/level/18)

这个挑战要求提供一个 `Solver` 合约，合约有一个方法 `whatIsTheMeaningOfLife()`，返回一个32字节数字。另外，要求 `Solver` 合约的代码需要非常小，最多不超过 10 字节。

按正常逻辑编写一个一个 `Solver` 合约很简单，但是字节码会超过 10 字节。可以借用 fallback 函数，不管调用哪个方法都返回42(0x2a)。然后通过最小代理合约的方式来部署合约运行字节码。

`Solver` 合约运行字节码 `0x602A60005260206000F3`：

```
[00]    PUSH1   2a
[02]    PUSH1   00
[04]    MSTORE  
[05]    PUSH1   20
[07]    PUSH1   00
[09]    RETURN
```

最终，RETURN 操作返回长度为 32 字节的数据，从内存地址 `0x00` 开始。这些数据包括前面的 `0x2a` 和接下来的零填充数据。


攻击者合约：
```
contract Attacker {
    MagicNum level;

    constructor(address level_) {
        level = MagicNum(level_);
    }

    function attack() public {
        address solverInstance;
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, shl(0x68, 0x69602A60005260206000F3600052600A6016F3))
            solverInstance := create(0, ptr, 0x13)
        }

        level.setSolver(solverInstance);
    }
}
```

执行脚本：
```
forge script script/Level18.s.sol:CallContractScript --rpc-url sepolia --broadcast
```

完整代码见：[这里](../../ethernaut/script/Level18.s.sol)

链上记录：
- [level(`MagicNum`)](https://sepolia.etherscan.io/address/0xdff2caaA0F67561139dB317905fE9636c5Ea2E99)
- [Attacker](https://sepolia.etherscan.io/tx/0x325D2bc3c4693841147286b9AeB593d85D04aE2a)
- [attack 交易](https://sepolia.etherscan.io/tx/0xfffec08fd1e3850ec9de4760c2accb84e7a2585c7624cf1427309829d70fe532)
- [Solver 合约](https://sepolia.etherscan.io/tx/0xf21c470b8ec3f834eb809dc3ef65b469d325dca4)