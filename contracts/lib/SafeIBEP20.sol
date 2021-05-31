// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "../interface/IBEP20.sol";

library SafeIBEP20 {
    function safeSymbol(IBEP20 token) internal view returns (string memory) {
        (bool success, bytes memory data) =
            address(token).staticcall(abi.encodeWithSelector(0x95d89b41));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeName(IBEP20 token) internal view returns (string memory) {
        (bool success, bytes memory data) =
            address(token).staticcall(abi.encodeWithSelector(0x06fdde03));
        return success && data.length > 0 ? abi.decode(data, (string)) : "???";
    }

    function safeDecimals(IBEP20 token) public view returns (uint8) {
        (bool success, bytes memory data) =
            address(token).staticcall(abi.encodeWithSelector(0x313ce567));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) =
            address(token).call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeIBEP20: Transfer failed"
        );
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) =
            address(token).call(
                abi.encodeWithSelector(0x23b872dd, from, address(this), amount)
            );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeIBEP20: TransferFrom failed"
        );
    }
}
