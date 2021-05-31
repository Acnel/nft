// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract CardsConfig {
    //创建卡的结构体
    struct Card {
        uint32 sqlId; //卡片数据库id
    }
    //卡牌人物组合结构
    struct HeroGroup {
        uint256 cardId;
        uint256 buffer;
    }
    struct HeroGroupList {
        uint256 sqlId; //组合id
        HeroGroup[] heroGroups; //人物战力加成映射
    }
    HeroGroupList[] heroGroupLists;
    Card[] public cards; //卡牌
    //卡片id与数据库id的映射
    mapping(uint256 => uint32) idToSqlId;
    mapping(uint32 => uint256) sqlIdToId;
    //卡牌组合id和数据库id
    mapping(uint256 => uint256) groupIdToSqlId;

    //创建卡牌
    function createCard(uint32 _sqlId) public {
        _createCard(_sqlId);
    }

    //添加人物组合
    function addHeroGroup(uint256 _id, uint256[][] memory _herosGroup) public {
        for (uint256 i = 0; i < _herosGroup.length; i++) {
            heroGroupLists[i].heroGroups.push(
                HeroGroup({
                    cardId: _herosGroup[i][0],
                    buffer: _herosGroup[i][1]
                })
            );
        }

        uint256 len = heroGroupLists.length - 1;
        groupIdToSqlId[len] = _id;
    }

    //添加卡牌
    function _createCard(uint32 _sqlId) internal {
        cards.push(Card(_sqlId));
        uint256 id = cards.length - 1;
        idToSqlId[id] = _sqlId;
        idToSqlId[id] = _sqlId;
        sqlIdToId[_sqlId] = id;
    }

    //返回组合信息
    //id组合id 人物id
    // function retGroupList(uint256 _id)
    //     public
    //     view
    //     returns (uint256[][] memory herosGroup)
    // {
    //     return heroGroupLists[_id];
    // }
}
