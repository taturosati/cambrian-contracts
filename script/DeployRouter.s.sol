// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

import {CambrianRouter} from "../src/CambrianRouter.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeployRouterScript is Script {
    using stdJson for string;

    function setUp() public {}

    function run() public {
        // get chain id
        string memory chainId = Strings.toString(block.chainid);

        string memory configFile = string.concat("./script/config/", chainId, ".json");

        // read config file
        string memory configFileJson = vm.readFile(configFile);

        // get sender address
        address upgrader = configFileJson.readAddress(".upgrader");

        vm.startBroadcast();

        ProxyAdmin proxyAdmin = new ProxyAdmin(upgrader);

        CambrianRouter cambrianRouter = new CambrianRouter();

        // Initialize calldata
        bytes memory data = abi.encodeWithSignature("initialize(address)", address(proxyAdmin));

        TransparentUpgradeableProxy proxy =
            new TransparentUpgradeableProxy(address(cambrianRouter), address(proxyAdmin), data);

        vm.stopBroadcast();

        string memory outputJson = "";

        string memory out = vm.serializeAddress(outputJson, "routerProxyAddress", address(proxy));

        out = vm.serializeAddress(outputJson, "routerImplementationAddress", address(cambrianRouter));

        out = vm.serializeAddress(outputJson, "proxyAdminAddress", address(proxyAdmin));

        // include chain id in output file name
        string memory outputFile = string.concat("./script/output/", chainId, ".json");

        vm.writeJson(out, outputFile);
    }
}
