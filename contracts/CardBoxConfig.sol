// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract CardBoxConfig {
    struct CardBox {
        uint8 level; //开槽等级
        uint32 exp; //升级所需经验
        uint8 addition; //加成
    }

    CardBox[] public CardBoxs;

    function _creatBox(
        uint8 _level,
        uint32 _exp,
        uint8 _addition
    ) internal {
        CardBoxs.push(CardBox(_level, _exp, _addition));
    }

    function creatBox(
        uint8 _level,
        uint32 _exp,
        uint8 _addition
    ) public {
        _creatBox(_level, _exp, _addition);
    }
}
