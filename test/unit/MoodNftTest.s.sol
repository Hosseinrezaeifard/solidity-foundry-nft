// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MoodNft} from "../../src/MoodNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNftTest is Test {
    MoodNft public moodNft;
    address public USER = makeAddr("user");
    address public STRANGER = makeAddr("stranger");
    string public happySvg = vm.readFile("./images/happy.svg");
    string public sadSvg = vm.readFile("./images/sad.svg");

    function setUp() public {
        moodNft = new MoodNft(svgToImageURI(happySvg), svgToImageURI(sadSvg));
    }

    function testConvertSvgToUri() public view {
        string
            memory expectedUri = "data:image/svg+xml;base64,PHN2ZyB2aWV3Qm94PSIwIDAgMjAwIDIwMCIgd2lkdGg9IjQwMCIgaGVpZ2h0PSI0MDAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGNpcmNsZSBjeD0iMTAwIiBjeT0iMTAwIiBmaWxsPSJ5ZWxsb3ciIHI9Ijc4IiBzdHJva2U9ImJsYWNrIiBzdHJva2Utd2lkdGg9IjMiIC8+PGcgY2xhc3M9ImV5ZXMiPiAgICA8Y2lyY2xlIGN4PSI3MCIgY3k9IjgyIiByPSIxMiIgLz4gICAgPGNpcmNsZSBjeD0iMTI3IiBjeT0iODIiIHI9IjEyIiAvPjwvZz48cGF0aCBkPSJtMTM2LjgxIDExNi41M2MuNjkgMjYuMTctNjQuMTEgNDItODEuNTItLjczIiBzdHlsZT0iZmlsbDpub25lOyBzdHJva2U6IGJsYWNrOyBzdHJva2Utd2lkdGg6IDM7IiAvPjwvc3ZnPg==";
        string
            memory svg = '<svg viewBox="0 0 200 200" width="400" height="400" xmlns="http://www.w3.org/2000/svg"><circle cx="100" cy="100" fill="yellow" r="78" stroke="black" stroke-width="3" /><g class="eyes">    <circle cx="70" cy="82" r="12" />    <circle cx="127" cy="82" r="12" /></g><path d="m136.81 116.53c.69 26.17-64.11 42-81.52-.73" style="fill:none; stroke: black; stroke-width: 3;" /></svg>';
        string memory actualUri = svgToImageURI(svg);
        assert(
            keccak256(abi.encodePacked(actualUri)) ==
                keccak256(abi.encodePacked(expectedUri))
        );
    }

    function testViewTokenUri() public {
        vm.prank(USER);
        moodNft.mintNft();
        console.log(moodNft.tokenURI(0));
        assert(
            keccak256(abi.encodePacked(moodNft.tokenURI(0))) !=
                keccak256(abi.encodePacked(""))
        );
    }

    function testFlipTokenToSad() public {
        vm.startPrank(USER);
        moodNft.mintNft();
        moodNft.flipMood(0);
        vm.stopPrank();
        assertEq(
            keccak256(abi.encodePacked(moodNft.tokenURI(0))),
            keccak256(
                abi.encodePacked(
                    moodNft.getBaseTokenURI(moodNft.getSadSvgImageUri())
                )
            )
        );
    }

    function testMoodStartsHappy() public {
        vm.startPrank(USER);
        moodNft.mintNft();
        vm.stopPrank();

        // Check that the mood starts as HAPPY
        assertEq(
            keccak256(abi.encodePacked(moodNft.tokenURI(0))),
            keccak256(
                abi.encodePacked(
                    moodNft.getBaseTokenURI(moodNft.getHappySvgImageUri())
                )
            )
        );
    }

    function testStrangerCannotFlipMood() public {
        vm.startPrank(USER);
        moodNft.mintNft();
        vm.stopPrank();

        vm.startPrank(STRANGER);
        vm.expectRevert(MoodNft.MoodNft__CantFlipMoodIfNotOwner.selector);
        moodNft.flipMood(0);
        vm.stopPrank();
    }

    function svgToImageURI(
        string memory svg
    ) public pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg)))
        );
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }
}
