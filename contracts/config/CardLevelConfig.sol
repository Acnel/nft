// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract CardLevelConfig {
    struct CardLevel {
        uint32 sqlId;
        uint16 fighting; //战斗力
        uint16 exp; //销毁卡片可得经验
        uint16 ASH; //质押的ASH
    }

    CardLevel[] public CardLevels;

    //卡片等级id与数据库id的映射
    mapping(uint256 => uint32) levelIdToSqlId;
    mapping(uint32 => uint256) sqlIdTolevelId;

    function _createLevel(
        uint32 _sqlId,
        uint16 _fighting,
        uint16 _exp,
        uint16 _ash
    ) internal {
        CardLevels.push(CardLevel(_sqlId, _fighting, _exp, _ash));
        uint256 id = CardLevels.length - 1;
        levelIdToSqlId[id] = _sqlId;
        sqlIdTolevelId[_sqlId] = id;
    }
    //新建/修改
    function addLevel(
        uint32 _sqlId,
        uint16 _fighting,
        uint16 _exp,
        uint16 _ash
    ) public {
        _createLevel( _sqlId, _fighting,  _exp, _ash);
    }

}
