// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MoodNft} from "../src/MoodNft.sol";

contract MintAndFlipMoodNft is Script {
    address public USER = makeAddr("user");

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "MoodNft",
            block.chainid
        );
        console.log("mostRecentlyDeployed", mostRecentlyDeployed);
        mintAndFlipMoodNft(mostRecentlyDeployed);
    }

    function mintAndFlipMoodNft(address contractAddress) public {
        console.log(
            "Minting and flipping a Mood NFT on contract:",
            contractAddress
        );
        vm.startPrank(USER);
        MoodNft(contractAddress).mintNft();
        MoodNft(contractAddress).flipMood(0);
        console.log("Mood flipped to sad");
        console.log(MoodNft(contractAddress).tokenURI(0));
        console.log(
            MoodNft(contractAddress).getBaseTokenURI(
                MoodNft(contractAddress).getSadSvgImageUri()
            )
        );
        vm.stopPrank();
    }
}
