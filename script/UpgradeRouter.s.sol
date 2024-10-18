// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {CambrianRouter} from "../src/CambrianRouter.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {
    ITransparentUpgradeableProxy,
    TransparentUpgradeableProxy
} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract UpgraderRouterScript is Script {
    using stdJson for string;

    function setUp() public {}

    function run() public {
        string memory chainId = Strings.toString(block.chainid);
        string memory outputFile = string.concat("./script/output/", chainId, ".json");

        string memory outputFileJson = vm.readFile(outputFile);

        ProxyAdmin proxyAdmin = ProxyAdmin(outputFileJson.readAddress(".proxyAdminAddress"));

        ITransparentUpgradeableProxy transparentProxy =
            ITransparentUpgradeableProxy(payable(outputFileJson.readAddress(".routerProxyAddress")));

        vm.startBroadcast();

        console.log(msg.sender);

        CambrianRouter cambrianRouterImplementation = new CambrianRouter();

        proxyAdmin.upgradeAndCall(transparentProxy, address(new CambrianRouter()), "");

        vm.stopBroadcast();

        string memory outputJson = "";

        string memory out = vm.serializeAddress(outputJson, "routerProxyAddress", address(transparentProxy));

        out = vm.serializeAddress(outputJson, "routerImplementationAddress", address(cambrianRouterImplementation));

        out = vm.serializeAddress(outputJson, "proxyAdminAddress", address(proxyAdmin));

        vm.writeJson(out, outputFile);
    }
}
