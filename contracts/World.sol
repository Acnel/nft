// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract World {
    uint256 worldTotalFighting = 0; //全服总战斗力
    uint256 worldCardTotalCount = 0; //全服卡牌总数量
    uint256 totalVolume = 0;

    // 获取全部总战斗力
    function getWorldTotalFighting() public view returns (uint256) {
        return worldTotalFighting;
    }

    //获取全部卡牌总数量
    function getWorldCardTotalCount() public view returns (uint256) {
        return worldCardTotalCount;
    }
}
