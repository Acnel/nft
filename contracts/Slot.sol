// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "./Card.sol";

//import "./Ash.sol";

contract Slot {
    Card public card;
    address owner = msg.sender;
    //装备的武功信息
    struct Kungfu {
        uint256 cardId; //卡片id 0代表天赋武功
        uint256 fight; //战力
    }
    //单个卡槽信息
    struct SlotInfo {
        uint256 level; //等级
        uint256 exp; //当前经验
        uint256 slotFight; //卡槽战力
        uint256 cardId; //卡片id
        uint256 fight; //人物战力
        uint256 buffer; //加成
        Kungfu[] kungfus; //装备的武功列表
        uint256 weaponId; //武器id
        uint256 weaponFight; //武器战力
        bool active; //激活状态
    }
    //用户卡槽信息
    struct UserSlotInfo {
        SlotInfo[] slots; //卡槽列表
        uint256 count; //卡片总数
        uint256 fight; //总战斗力
    }
    //卡槽经验加成配置
    struct LevelConfig {
        uint256 exp;
        uint256 buffer;
    }

    event Upgrade();

    mapping(address => UserSlotInfo) public ownerUserSlotInfos;

    LevelConfig[] public levelConfigs;

    //初始化
    constructor() public {
        levelConfigs.push(LevelConfig({exp: 0, buffer: 0}));
        levelConfigs.push(LevelConfig({exp: 100, buffer: 10}));
        levelConfigs.push(LevelConfig({exp: 300, buffer: 20}));
        levelConfigs.push(LevelConfig({exp: 500, buffer: 30}));
        levelConfigs.push(LevelConfig({exp: 700, buffer: 40}));
        levelConfigs.push(LevelConfig({exp: 900, buffer: 50}));
    }

    function _addCard(
        address _owner,
        uint256 _cardTag,
        uint256 _cardId
    ) internal {
        //用户卡槽信息
        UserSlotInfo storage usi = ownerUserSlotInfos[_owner];
        SlotInfo[] storage slots = usi.slots;
        //获取放置卡片的卡槽
        SlotInfo storage si = slots[_cardTag];
        //获取卡片战斗力
        uint256 cardFight = card.getFight(_cardId);
        if (si.cardId == 0) {
            si.cardId = _cardId;
            si.fight = cardFight;
            si.active = true;
            usi.count++;
        } else {
            si.cardId = _cardId;
            si.fight = cardFight;
        }
        //计算用户总战斗力
        _calculateUserFight(_owner);
    }

    //装备武功
    function _equipKungfu(
        address _owner,
        uint256 _cardTag,
        uint256 _cardId,
        uint8 _index
    ) internal {
        //用户卡槽信息
        UserSlotInfo storage usi = ownerUserSlotInfos[_owner];
        SlotInfo[] storage slots = usi.slots;
        //获取放置卡片的卡槽
        SlotInfo storage si = slots[_cardTag];
        Kungfu[] storage kungfus = si.kungfus;
        //获取武功卡槽
        Kungfu storage kf = kungfus[_index];
        //获取卡片战斗力
        uint256 cardFight = card.getFight(_cardId);

        kf.cardId = _cardId;
        kf.fight = cardFight;
    }

    //装备武器
    function _equipWeapon(
        address _owner,
        uint256 _cardTag,
        uint256 _cardId
    ) internal {
        //用户卡槽信息
        UserSlotInfo storage usi = ownerUserSlotInfos[_owner];
        SlotInfo[] storage slots = usi.slots;
        //获取放置卡片的卡槽
        SlotInfo storage si = slots[_cardTag];
        //获取卡片战斗力
        uint256 cardFight = card.getFight(_cardId);
        si.weaponId = _cardId;
        si.weaponFight = cardFight;
    }

    //升级卡槽
    function _upgrade(
        address _owner,
        uint256 _cardTag,
        uint256 _exp
    ) internal {
        //用户卡槽信息
        UserSlotInfo storage usi = ownerUserSlotInfos[_owner];
        SlotInfo[] storage slots = usi.slots;
        //获取放置卡片的卡槽
        SlotInfo storage si = slots[_cardTag];

        si.exp += _exp;
        uint256 buffer = 0;
        for (uint256 index = 0; index < levelConfigs.length; index++) {
            if (levelConfigs[index].exp > si.exp) {
                break;
            }
            buffer = levelConfigs[index].buffer;
        }
        if (buffer > si.buffer) {
            si.buffer = buffer;
        }
    }

    //重新计算用户总战斗力
    function _calculateUserFight(address _owner) internal {
        //用户卡槽信息
        UserSlotInfo storage usi = ownerUserSlotInfos[_owner];
        SlotInfo[] storage slots = usi.slots;

        uint256 fight = 0;
        for (uint256 i = 0; i < slots.length; i++) {
            //计算卡槽基本战斗力
            if (slots[i].active == true) {
                //装备的武功加成战斗力
                uint256 KungfuFight = 0;
                for (uint256 j = 0; j < slots[i].kungfus.length; j++) {
                    KungfuFight += slots[i].kungfus[j].fight;
                }
                //计算当前卡槽战斗力(未加成)
                uint256 slotFight =
                    slots[i].fight + slots[i].weaponFight + KungfuFight;
                //加成
                uint256 buffer = 100 + slots[i].buffer;

                fight += (slotFight * buffer) / 100;
            }
            continue;
        }
        usi.fight = fight;
    }

    //放置卡片
    function addCard(uint256 _cardTag, uint256 _cardId) public {
        _addCard(owner, _cardTag, _cardId);
    }

    //装备武功
    function equipKungfu(
        uint256 _cardTag,
        uint256 _cardId,
        uint8 _index
    ) public {
        _equipKungfu(owner, _cardTag, _cardId, _index);
    }

    //升级卡槽
    function upgrade(uint256 _cardTag, uint256 _exp) public {
        _upgrade(owner, _cardTag, _exp);
    }

    //获取用户卡槽信息
    function getUserSlotInfo()
        external
        view
        returns (SlotInfo[] memory, uint256 fight)
    {
        UserSlotInfo storage usi = ownerUserSlotInfos[owner];

        return (usi.slots, usi.fight);
    }

    //获取单个卡槽信息
    function getSoltInfo(uint256 cardTag)
        external
        view
        returns (SlotInfo memory)
    {
        return ownerUserSlotInfos[owner].slots[cardTag];
    }
}
