// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
//卡包
contract PageConfig {
    //创建卡包的结构体
    struct Package {
        uint32 sqlId; //卡包数据库id
    }

    Package[] public packages;

    //卡包id与数据库id的映射
    mapping(uint256 => uint32) pageIdToSqlId;
    mapping(uint32 => uint256) sqlIdToPageId;

    //创建卡包
    function createCard(uint32 _sqlId) public {
        _createCard(_sqlId);
    }
   
    function _createCard(uint32 _sqlId) internal {
        packages.push(Package(_sqlId));
        uint256 id = packages.length - 1;
        pageIdToSqlId[id] = _sqlId;
        sqlIdToPageId[_sqlId] = id;
    }
    
}






