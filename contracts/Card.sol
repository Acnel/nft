// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./config/CardLevelConfig.sol";
import "./lib/Util.sol";
import "./config/CardsConfig.sol";
import "./config/ManagerConfig.sol";

//import "./AshToken.sol";

contract Card {
    CardsConfig public cardConfig;
    //AshToken public ashToken;
    ManagerConfig public managerConfig;
    mapping(uint256 => uint256) public Fights;
    mapping(uint256 => uint256) public Exps;
    struct CardInfo {
        uint256 sqlId; //卡片id
        uint8 level; //卡片品质
        uint256 ASH; //卡片质押的ASH币
    }
    CardInfo[] public CardInfos;
    mapping(uint256 => CardInfo) cardIdToCardInfo;

    constructor() public {
        Fights[0] = 200;
        Fights[1] = 400;
        Fights[2] = 800;
        Fights[3] = 1600;
        Fights[4] = 2000;

        Exps[0] = 20;
        Exps[1] = 30;
        Exps[2] = 40;
        Exps[3] = 50;
        Exps[4] = 60;
    }

    mapping(uint256 => address) cardToAddress; //cardid和地址的映射

    //添加设置战斗力
    function setFight(uint256 rarity, uint256 fight) external {
        Fights[rarity] = fight;
    }

    //获取卡牌的战斗力
    function getFight(uint256 cardId) external view returns (uint256) {
        return Fights[uint16(cardId >> 192)];
    }

    //获取所有人物组合
    // function getHeroGroup(uint256 _cardTag) public view returns (uint256) {
    //     cardConfig.retGroupList(_cardTag);
    // }

    //获取卡牌地址
    function getCardAddress(uint256 cardId) public view returns (address) {
        return cardToAddress[cardId];
    }

    //质押抽卡
    function _openCard(uint256 ash) internal {
        //    if(ash<100){
        //    }elseif(){
        //    }
    }

    //返回卡片信息
    function getCardInfo(uint256 cardId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        CardInfo memory cardinfo = cardIdToCardInfo[cardId];
        uint256 ash = cardinfo.ASH;
        uint256 exp = Exps[cardinfo.level];
        uint256 fight = Fights[cardinfo.level];

        return (ash, exp, fight);
    }

    //释放卡片
    function brunCard(uint256 cardId) internal {
        require(
            msg.sender == cardToAddress[cardId],
            "msg.sender must be owner"
        );

        //释放卡片后返还质押的ASH代币
        //ashToken.transfer(cardToAddress[cardId], cardIdToCardInfo[cardId].ASH);
    }
}
