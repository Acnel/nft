pragma solidity >=0.4.22 <0.9.0;

// SPDX-License-Identifier: SimPL-2.0

library Util {
    bytes4 internal constant ERC721_RECEIVER_RETURN = 0x150b7a02;
    bytes4 internal constant ERC721_RECEIVER_EX_RETURN = 0x0f7b88e3;

    uint256 public constant UDENO = 10**10;
    int256 public constant SDENO = 10**10;

    uint256 public constant RARITY_GREEN = 0;
    uint256 public constant RARITY_BLUE = 1;
    uint256 public constant RARITY_PURPLE = 2;
    uint256 public constant RARITY_ORANGE = 3;
    uint256 public constant RARITY_GOLD = 4;

    bytes public constant BASE64_CHARS =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
}
