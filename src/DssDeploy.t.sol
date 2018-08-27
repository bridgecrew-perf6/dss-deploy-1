pragma solidity ^0.4.24;

import {DSTest} from "ds-test/test.sol";
import {DSValue} from "ds-value/value.sol";
import {DSRoles} from "ds-roles/roles.sol";

import {Adapter, ETHAdapter} from "dss/join.sol";

import "./DssDeploy.sol";

contract DssDeployTest is DSTest {
    VatFab vatFab;
    PitFab pitFab;
    DripFab dripFab;
    VowFab vowFab;
    CatFab catFab;
    TokenFab tokenFab;
    DaiAptFab daiAptFab;
    FlapFab flapFab;
    FlopFab flopFab;
    MomFab momFab;
    FlipFab flipFab;
    PriceFab priceFab;

    DssDeploy dssDeploy;

    DSToken gov;
    DSValue pipETH;
    DSValue pipDGX;

    DSRoles authority;

    function setUp() public {
        vatFab = new VatFab();
        pitFab = new PitFab();
        dripFab = new DripFab();
        vowFab = new VowFab();
        catFab = new CatFab();
        tokenFab = new TokenFab();
        daiAptFab = new DaiAptFab();
        flapFab = new FlapFab();
        flopFab = new FlopFab();
        momFab = new MomFab();

        flipFab = new FlipFab();
        priceFab = new PriceFab();

        uint startGas = gasleft();
        dssDeploy = new DssDeploy(vatFab, pitFab, dripFab, vowFab, catFab, tokenFab, daiAptFab, flapFab, flopFab, momFab, flipFab, priceFab);
        uint endGas = gasleft();
        emit log_named_uint("Deploy DssDeploy", startGas - endGas);

        gov = new DSToken("GOV");
        pipETH = new DSValue();
        pipDGX = new DSValue();
        authority = new DSRoles();
        authority.setRootUser(this, true);
    }

    function testDeploy() public {
        uint startGas = gasleft();
        dssDeploy.deployContracts(gov);
        uint endGas = gasleft();

        startGas = gasleft();
        ETHAdapter ethAdapter = new ETHAdapter(dssDeploy.vat(), "ETH");
        dssDeploy.deployIlk("ETH", ethAdapter, pipETH);
        endGas = gasleft();
        emit log_named_uint("Make Vox Tub", startGas - endGas);

        startGas = gasleft();
        DSToken dgx = new DSToken("DGX");
        Adapter adapterDGX = new Adapter(dssDeploy.vat(), "DGX", dgx);
        dssDeploy.deployIlk("DGX", adapterDGX, pipDGX);
        endGas = gasleft();
        emit log_named_uint("Make Vox Tub", startGas - endGas);

        startGas = gasleft();
        dssDeploy.configParams();
        endGas = gasleft();
        emit log_named_uint("Config Params", startGas - endGas);

        startGas = gasleft();
        dssDeploy.verifyParams();
        endGas = gasleft();
        emit log_named_uint("Verify Params", startGas - endGas);

        startGas = gasleft();
        dssDeploy.configAuth(authority);
        endGas = gasleft();
        emit log_named_uint("Config Auth", startGas - endGas);

        ethAdapter.join.value(10)();
        assertEq(dssDeploy.vat().gem("ETH", bytes32(address(this))), 10);
    }

    function testFailStep() public {
        dssDeploy.configParams();
    }
}