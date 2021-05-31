// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./JYToken.sol";
import "./lib/Ownable.sol";
import "./lib/Safemath.sol";
import "./lib/SafeIBEP20.sol";

contract MasterChef is Ownable {
    using SafeMath for uint256;
    using SafeIBEP20 for IBEP20;
    struct UserInfo {
        uint256 amount; //质押的代币数量
        uint256 rewardDebt; //已经获取的奖励数
    }

    struct PoolInfo {
        IBEP20 lpToken; // lpToken代币地址
        uint256 allocPoint; // 质押池的分配比例
        uint256 lastRewardBlock; // 上一次分配奖励的区块数
        uint256 accJyPerShare; // 起始点位
    }
    //jy代币
    IBEP20 public jy;
    //管理员地址
    address public devaddr;
    // 每个区块挖出来的jy的数量.
    uint256 public jyPerBlock;
    //矿池信息
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    //是总共分配的点数
    uint256 public totalAllocPoint = 0;
    //开始区块
    uint256 public startBlock;
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    constructor(
        IBEP20 _jy,
        address _devaddr,
        uint256 _jyPerBlock,
        uint256 _startBlock
    ) public {
        jy = _jy;
        devaddr = _devaddr;
        jyPerBlock = _jyPerBlock;
        startBlock = _startBlock;
    }

    //添加质押池
    function add(
        uint256 _allocPoint,
        IBEP20 _lpToken,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accJyPerShare: 0
            })
        );
    }

    //更新质押池
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    //更新矿池的奖励
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    //更新质押池收益
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 jyReward = jyPerBlock.mul(pool.allocPoint).div(totalAllocPoint);

        //增加用户收益数据

        pool.accJyPerShare = pool.accJyPerShare.add(
            jyReward.mul(1e18).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    //用户质押代币进行挖矿
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending =
                user.amount.mul(pool.accJyPerShare).div(1e18).sub(
                    user.rewardDebt
                );
            safeJyTransfer(msg.sender, pending);
        }
        //用户质押代币转账
        pool.lpToken.safeTransferFrom(address(this), _amount);
        //重新计算用户质押的代币总数
        user.amount = user.amount.add(_amount);
        //
        user.rewardDebt = user.amount.mul(pool.accJyPerShare).div(1e18);
        emit Deposit(msg.sender, _pid, _amount);
    }

    //解除质押
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount);
        updatePool(_pid);
        uint256 pending =
            user.amount.mul(pool.accJyPerShare).div(1e18).sub(user.rewardDebt);
        safeJyTransfer(msg.sender, pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accJyPerShare).div(1e12);
        //返还用户质押的代币
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    //挖矿奖励提取
    function safeJyTransfer(address _to, uint256 _amount) internal {
        uint256 jyBal = jy.balanceOf(address(this));
        if (_amount > jyBal) {
            jy.transfer(_to, jyBal);
        } else {
            jy.transfer(_to, _amount);
        }
    }
}
