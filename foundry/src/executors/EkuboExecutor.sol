// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.26;

import "@interfaces/IExecutor.sol";
import {
    IERC20,
    SafeERC20
} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ICallback} from "@interfaces/ICallback.sol";

contract EkuboExecutor is IExecutor, ICallback {
    ICore immutable core;

    function swap(uint256 amountIn, bytes calldata data)
        external
        payable
        returns (uint256 calculatedAmount)
    {

    }

    function handleCallback(bytes calldata data)
        external
        returns (bytes memory)
    {
        verifyCallback(data);
        return _unlockCallback(data);
    }

    function verifyCallback(bytes calldata) public view {
        require(msg.sender == address(core));
    }

    function decodeData(bytes calldata data)
        internal
        pure
        returns (
            address tokenIn,
            address tokenOut,
            bool zeroForOne,
            address callbackExecutor,
            UniswapV4Pool[] memory pools
        )
    {
        if (data.length < 87) {
            revert UniswapV4Executor__InvalidDataLength();
        }

        tokenIn = address(bytes20(data[0:20]));
        tokenOut = address(bytes20(data[20:40]));
        zeroForOne = (data[40] != 0);
        callbackExecutor = address(bytes20(data[41:61]));

        uint256 poolsLength = (data.length - 61) / 26; // 26 bytes per pool object
        pools = new UniswapV4Pool[](poolsLength);
        bytes memory poolsData = data[61:];
        uint256 offset = 0;
        for (uint256 i = 0; i < poolsLength; i++) {
            address intermediaryToken;
            uint24 fee;
            int24 tickSpacing;

            // slither-disable-next-line assembly
            assembly {
                intermediaryToken := mload(add(poolsData, add(offset, 20)))
                fee := shr(232, mload(add(poolsData, add(offset, 52))))
                tickSpacing := shr(232, mload(add(poolsData, add(offset, 55))))
            }
            pools[i] = UniswapV4Pool(intermediaryToken, fee, tickSpacing);
            offset += 26;
        }
    }
}
