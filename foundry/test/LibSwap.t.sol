// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../lib/LibSwap.sol";

contract LibSwapTest is Test {
    using LibSwap for bytes;

    function testSwap() public view {
        uint8 tokenInIndex = 1;
        uint8 tokenOutIndex = 2;
        uint24 split = 3;
        address executor = 0x1234567890123456789012345678901234567890;
        bytes4 selector = 0x12345678;
        bytes memory protocolData = abi.encodePacked(uint256(456));

        bytes memory swap = abi.encodePacked(
            tokenInIndex, tokenOutIndex, split, executor, selector, protocolData
        );
        this.assertSwap(
            swap, tokenInIndex, tokenOutIndex, split, executor, selector
        );
    }

    // This is necessary so that the compiler accepts bytes as a LibSwap.sol
    function assertSwap(
        bytes calldata swap,
        uint8 tokenInIndex,
        uint8 tokenOutIndex,
        uint24 split,
        address executor,
        bytes4 selector
    ) public pure {
        assert(swap.tokenInIndex() == tokenInIndex);
        assert(swap.tokenOutIndex() == tokenOutIndex);
        assert(swap.splitPercentage() == split);
        assert(swap.executor() == executor);
        assert(swap.executorSelector() == selector);
    }
}
