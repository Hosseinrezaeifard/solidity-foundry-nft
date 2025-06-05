// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DeployMoodNft} from "../../script/DeployMoodNft.s.sol";
import {MoodNft} from "../../src/MoodNft.sol";

contract MoodNftInteractionsTest is Test {
    MoodNft public moodNft;
    address public USER = makeAddr("user");
    address public STRANGER = makeAddr("stranger");

    function setUp() external {
        DeployMoodNft deployer = new DeployMoodNft();
        moodNft = deployer.run();
    }

    function testUserCanMintAndFlipMoodNft() public {
        vm.startPrank(USER);
        moodNft.mintNft();
        moodNft.flipMood(0);
        vm.stopPrank();

        // Check that the mood was flipped to SAD
        assertEq(
            keccak256(abi.encodePacked(moodNft.tokenURI(0))),
            keccak256(
                abi.encodePacked(
                    moodNft.getBaseTokenURI(moodNft.getSadSvgImageUri())
                )
            )
        );
    }

    function testCanFlipMoodMultipleTimes() public {
        vm.startPrank(USER);
        moodNft.mintNft();

        // First flip to SAD
        moodNft.flipMood(0);
        assertEq(
            keccak256(abi.encodePacked(moodNft.tokenURI(0))),
            keccak256(
                abi.encodePacked(
                    moodNft.getBaseTokenURI(moodNft.getSadSvgImageUri())
                )
            )
        );

        // Second flip back to HAPPY
        moodNft.flipMood(0);
        assertEq(
            keccak256(abi.encodePacked(moodNft.tokenURI(0))),
            keccak256(
                abi.encodePacked(
                    moodNft.getBaseTokenURI(moodNft.getHappySvgImageUri())
                )
            )
        );
        vm.stopPrank();
    }

    function testMultipleUsersCanMintAndFlip() public {
        // First user mints and flips
        vm.startPrank(USER);
        moodNft.mintNft();
        moodNft.flipMood(0);
        vm.stopPrank();

        // Second user mints and flips
        vm.startPrank(STRANGER);
        moodNft.mintNft();
        moodNft.flipMood(1);
        vm.stopPrank();

        // Check both NFTs
        assertEq(
            keccak256(abi.encodePacked(moodNft.tokenURI(0))),
            keccak256(
                abi.encodePacked(
                    moodNft.getBaseTokenURI(moodNft.getSadSvgImageUri())
                )
            )
        );
        assertEq(
            keccak256(abi.encodePacked(moodNft.tokenURI(1))),
            keccak256(
                abi.encodePacked(
                    moodNft.getBaseTokenURI(moodNft.getSadSvgImageUri())
                )
            )
        );
    }
}
