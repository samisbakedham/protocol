// SPDX-License-Identifier: MIT
pragma solidity ^0.6.7;

import "../strategy-spookyswap-base.sol";

contract StrategyBooFtmMaticLp is StrategyBooFarmLPBase {
    uint256 public ftm_matic_poolid = 54;
    // Token addresses
    address public ftm_matic_lp = 0x7051C6F0C1F1437498505521a3bD949654923fE1;
    address public matic = 0x40DF1Ae6074C35047BFF66675488Aa2f9f6384F3;

    constructor(
        address _governance,
        address _strategist,
        address _controller,
        address _timelock
    )
        public
        StrategyNettFarmLPBase(
            ftm_matic_lp,
            ftm_matic_poolid,
            _governance,
            _strategist,
            _controller,
            _timelock
        )
    {
        swapRoutes[matic] = [boo, ftm, matic];
        swapRoutes[ftm] = [boo, ftm];
    }

    // **** Views ****

    function getName() external pure override returns (string memory) {
        return "StrategyBooFtmMaticLp";
    }
}
