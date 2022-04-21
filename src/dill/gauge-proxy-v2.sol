// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1; // ^0.6.7; //^0.7.5;

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {
        // return address(uint160(account));
        return payable(address(uint160(account)));

    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

library SafeERC20 {
    
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + (
            value
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) - (
            value
            // ,
            // "SafeERC20: decreased allowance below zero"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    // constructor() public {
        constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract Gauge is ReentrancyGuard {
    
    using SafeERC20 for IERC20;

    IERC20 public constant PICKLE =
        IERC20(0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5);
    IERC20 public constant DILL =
        IERC20(0xbBCf169eE191A1Ba7371F30A1C344bFC498b29Cf);
    address public constant TREASURY =
        address(0x066419EaEf5DE53cc5da0d8702b990c5bc7D1AB3);

    IERC20 public immutable TOKEN;
    address public immutable DISTRIBUTION;
    uint256 public constant DURATION = 7 days;

    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    modifier onlyDistribution() {
        require(
            msg.sender == DISTRIBUTION,
            "Caller is not RewardsDistribution contract"
        );
        _;
    }

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    uint256 public derivedSupply;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) public derivedBalances;
    mapping(address => uint256) private _base;

    constructor(address _token) public {
        TOKEN = IERC20(_token);
        DISTRIBUTION = msg.sender;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored + (
                ((lastTimeRewardApplicable()
                    - (lastUpdateTime))
                    * (rewardRate)
                    * (1e18))
                    / (derivedSupply)
            );
    }

    function derivedBalance(address account) public view returns (uint256) {
        uint256 _balance = _balances[account];
        uint256 _derived = _balance * (40) / (100);
        uint256 _adjusted = (
            _totalSupply * (DILL.balanceOf(account)) / (DILL.totalSupply())
        ) * (60) / (100);
        return Math.min(_derived + (_adjusted), _balance);
    }

    function kick(address account) public {
        uint256 _derivedBalance = derivedBalances[account];
        derivedSupply -= (_derivedBalance);
        _derivedBalance = derivedBalance(account);
        derivedBalances[account] = _derivedBalance;
        derivedSupply += (_derivedBalance);
    }

    function earned(address account) public view returns (uint256) {
        return
            (derivedBalances[account]
                * (rewardPerToken() - (userRewardPerTokenPaid[account]))
                / (1e18))
                + (rewards[account]);
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate * (DURATION);
    }

    function depositAll() external {
        _deposit(TOKEN.balanceOf(msg.sender), msg.sender);
    }

    function deposit(uint256 amount) external {
        _deposit(amount, msg.sender);
    }

    function depositFor(uint256 amount, address account) external {
        _deposit(amount, account);
    }

    function _deposit(uint256 amount, address account)
        internal
        nonReentrant
        updateReward(account)
    {
        require(amount > 0, "Cannot stake 0");
        _totalSupply += (amount);
        _balances[account] += (amount);
        emit Staked(account, amount);
        TOKEN.safeTransferFrom(account, address(this), amount);
    }

    function withdrawAll() external {
        _withdraw(_balances[msg.sender]);
    }

    function withdraw(uint256 amount) external {
        _withdraw(amount);
    }

    function _withdraw(uint256 amount)
        internal
        nonReentrant
        updateReward(msg.sender)
    {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply -= (amount);
        _balances[msg.sender] -= (amount);
        TOKEN.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public nonReentrant updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            PICKLE.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function exit() external {
        _withdraw(_balances[msg.sender]);
        getReward();
    }

    function notifyRewardAmount(uint256 reward)
        external
        onlyDistribution
        updateReward(address(0))
    {
        PICKLE.safeTransferFrom(DISTRIBUTION, address(this), reward);
        if (block.timestamp >= periodFinish) {
            rewardRate = reward / (DURATION);
        } else {
            uint256 remaining = periodFinish - (block.timestamp);
            uint256 leftover = remaining * (rewardRate);
            rewardRate = (reward + leftover) / DURATION;
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 balance = PICKLE.balanceOf(address(this));
        require(
            rewardRate <= balance / (DURATION),
            "Provided reward too high"
        );

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + DURATION;
        emit RewardAdded(reward);
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
        if (account != address(0)) {
            kick(account);
        }
    }

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
}

interface MasterChef {
    function deposit(uint256, uint256) external;

    function withdraw(uint256, uint256) external;

    function userInfo(uint256, address)
        external
        view
        returns (uint256, uint256);
}

contract ProtocolGovernance {
    /// @notice governance address for the governance contract
    address public governance;
    address public pendingGovernance;

    /**
     * @notice Allows governance to change governance (for future upgradability)
     * @param _governance new governance address to set
     */
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "setGovernance: !gov");
        pendingGovernance = _governance;
    }

    /**
     * @notice Allows pendingGovernance to accept their role as governance (protection pattern)
     */
    function acceptGovernance() external {
        require(
            msg.sender == pendingGovernance,
            "acceptGovernance: !pendingGov"
        );
        governance = pendingGovernance;
    }
}

contract MasterDill {
    

    /// @notice EIP-20 token name for this token
    string public constant name = "Master DILL";

    /// @notice EIP-20 token symbol for this token
    string public constant symbol = "mDILL";

    /// @notice EIP-20 token decimals for this token
    uint8 public constant decimals = 18;

    /// @notice Total number of tokens in circulation
    uint256 public totalSupply = 1e18;

    mapping(address => mapping(address => uint256)) internal allowances;
    mapping(address => uint256) internal balances;

    /// @notice The standard EIP-20 transfer event
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice The standard EIP-20 approval event
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    constructor() public {
        balances[msg.sender] = 1e18;
        emit Transfer(address(0x0), msg.sender, 1e18);
    }

    /**
     * @notice Get the number of tokens `spender` is approved to spend on behalf of `account`
     * @param account The address of the account holding the funds
     * @param spender The address of the account spending the funds
     * @return The number of tokens approved
     */
    function allowance(address account, address spender)
        external
        view
        returns (uint256)
    {
        return allowances[account][spender];
    }

    /**
     * @notice Approve `spender` to transfer up to `amount` from `src`
     * @dev This will overwrite the approval amount for `spender`
     *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
     * @param spender The address of the account which may transfer tokens
     * @param amount The number of tokens that are approved (2^256-1 means infinite)
     * @return Whether or not the approval succeeded
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        allowances[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Get the number of tokens held by the `account`
     * @param account The address of the account to get the balance of
     * @return The number of tokens held
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    /**
     * @notice Transfer `amount` tokens from `msg.sender` to `dst`
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transfer(address dst, uint256 amount) external returns (bool) {
        _transferTokens(msg.sender, dst, amount);
        return true;
    }

    /**
     * @notice Transfer `amount` tokens from `src` to `dst`
     * @param src The address of the source account
     * @param dst The address of the destination account
     * @param amount The number of tokens to transfer
     * @return Whether or not the transfer succeeded
     */
    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool) {
        address spender = msg.sender;
        uint256 spenderAllowance = allowances[src][spender];

        // if (spender != src && spenderAllowance != uint256(-1)) { // type(uint256).max
        if (spender != src && spenderAllowance != type(uint256).max) {
            uint256 newAllowance = spenderAllowance - (
                amount
                // ,
                // "transferFrom: exceeds spender allowance"
            );
            allowances[src][spender] = newAllowance;

            emit Approval(src, spender, newAllowance);
        }

        _transferTokens(src, dst, amount);
        return true;
    }

    function _transferTokens(
        address src,
        address dst,
        uint256 amount
    ) internal {
        require(src != address(0), "_transferTokens: zero address");
        require(dst != address(0), "_transferTokens: zero address");

        balances[src] = balances[src] - (
            amount
            // ,
            // "_transferTokens: exceeds balance"
        );
        balances[dst] += (amount
        // ,
        //  "_transferTokens: overflows"
         );
        emit Transfer(src, dst, amount);
    }
}

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private initializing;

    /**
     * @dev Modifier to use in the initializer function of a contract.
     */
    modifier initializer() {
        require(
            initializing || isConstructor() || !initialized,
            "Contract instance has already been initialized"
        );

        bool isTopLevelCall = !initializing;
        if (isTopLevelCall) {
            initializing = true;
            initialized = true;
        }

        _;

        if (isTopLevelCall) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;
}

contract GaugeProxyV2 is ProtocolGovernance, Initializable {
    
    using SafeERC20 for IERC20;

    MasterChef public constant MASTER =
        MasterChef(0xbD17B1ce622d73bD438b9E658acA5996dc394b0d);
    IERC20 public constant DILL =
        IERC20(0xbBCf169eE191A1Ba7371F30A1C344bFC498b29Cf);
    IERC20 public constant PICKLE =
        IERC20(0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5);

    IERC20 public TOKEN;

    uint256 public pid;

    address[] internal _tokens;

    // token => gauge
    mapping(address => address) public gauges;

    mapping(address => uint256) public gaugeWithNegativeWeight;

    uint256 public constant week = 7 days;
    uint256 public constant weekSeconds = 604800;
    // epoch time stamp
    uint256 public firstDistribution;
    uint256 public prevDistributionId;
    uint256 public currentId;
    address[] internal _tokensTemp;

    mapping(address => int256) public usedWeights; // msg.sender => total voting weight of user
    mapping(address => address[]) public tokenVote; // msg.sender => token
    mapping(address => mapping(address => int256)) public votes; // msg.sender => votes
    mapping(address => int256[]) public weights; // token => weight [period id]
    int256[] public totalWeight; // [period id]

    struct delegateData {
        // delegated address
        address delegate;
        // previous delegated address if updated, else zero address
        address prevDelegate;
        // period id when delegate address was updated
        uint256 updatePeriodId;
        // endPeriod if defined. Else 0.
        uint256 endPeriod;
        // If no endPeriod
        bool indefinite;
        // Period => Boolean (if delegate address can vote in that period)
        mapping(uint256 => bool) blockDelegate;
    }

    mapping(address => delegateData) public delegations;

    function getActualCurrentPeriodId() public view returns (uint256) {
        uint256 lastPeriodEndTimestamp = (firstDistribution +
            (currentId * weekSeconds));
        if (lastPeriodEndTimestamp < block.timestamp) {
            uint256 weeksElapsed = (block.timestamp - lastPeriodEndTimestamp) /
                60 /
                60 /
                24 /
                7;

            return currentId + weeksElapsed + 1;
        }
    }

    function tokens() external view returns (address[] memory) {
        return _tokens;
    }

    function getGauge(address _token) external view returns (address) {
        return gauges[_token];
    }

    function initialize(uint256 _firstDistribution) public initializer {
        TOKEN = IERC20(address(new MasterDill()));
        governance = msg.sender;
        firstDistribution = _firstDistribution;
        currentId = 0; //1;
        prevDistributionId = 0;
    }

    function _updateCurrentId() internal {
        uint256 prevPeriodId = currentId;
        currentId = getActualCurrentPeriodId();
        for (uint256 i = prevPeriodId + 1; i <= currentId; i++) {
            totalWeight[i] = totalWeight[i-1];
        }
    }

    // Reset votes to 0
    function reset() external {
        // check if voting cycle is over then update ballotId
        _updateCurrentId();
        _reset(msg.sender);
    }

    // Reset votes to 0
    function _reset(address _owner) internal {
        address[] storage _tokenVote = tokenVote[_owner];
        uint256 _tokenVoteCnt = _tokenVote.length;
        for (uint256 i = 0; i < _tokenVoteCnt; i++) {
            address _token = _tokenVote[i];
            int256 _votes = votes[_owner][_token];

            if (_votes != 0) {
                totalWeight[currentId] -= (
                    _votes > 0 ? _votes : -_votes
                );
                weights[_token][currentId] -= (
                    _votes
                );

                votes[_owner][_token] = 0;
            }
        }

        delete tokenVote[_owner];
    }

    // Adjusts _owner's votes according to latest _owner's DILL balance
    function poke(address _owner) public {
        _updateCurrentId();
        address[] memory _tokenVote = tokenVote[_owner];
        uint256 _tokenCnt = _tokenVote.length;
        int256[] memory _weights = new int256[](_tokenCnt);

        int256 _prevUsedWeight = usedWeights[_owner];
        int256 _weight = int256(DILL.balanceOf(_owner));

        for (uint256 i = 0; i < _tokenCnt; i++) {
            int256 _prevWeight = votes[_owner][_tokenVote[i]];
            _weights[i] = _prevWeight * (_weight) / (_prevUsedWeight);
        }
        _vote(_owner, _tokenVote, _weights);
    }

    function _vote(
        address _owner,
        address[] memory _tokenVote,
        int256[] memory _weights
    ) internal {
        _reset(_owner);
        uint256 _tokenCnt = _tokenVote.length;
        int256 _weight = int256(DILL.balanceOf(_owner));
        int256 _totalVoteWeight = 0;
        int256 _usedWeight = 0;

        for (uint256 i = 0; i < _tokenCnt; i++) {
            _totalVoteWeight += (
                _weights[i] > 0 ? _weights[i] : -_weights[i]
            );
        }

        for (uint256 i = 0; i < _tokenCnt; i++) {
            address _token = _tokenVote[i];
            address _gauge = gauges[_token];
            int256 _tokenWeight = _weights[i] * (_weight) / (
                _totalVoteWeight
            );
            weights[_token][currentId] = weights[_token][currentId - 1];
            if (_gauge != address(0x0)) {
                weights[_token][currentId] += (
                    _tokenWeight
                );
                votes[_owner][_token] = _tokenWeight;
                tokenVote[_owner].push(_token);

                if (_tokenWeight < 0) {
                    _tokenWeight = -_tokenWeight;
                }

                _usedWeight += (_tokenWeight);
                totalWeight[currentId] += (
                    _tokenWeight
                );
            }
        }

        usedWeights[_owner] = _usedWeight;
    }

    // Vote with DILL on a gauge
    function vote(address[] calldata _tokenVote, int256[] calldata _weights)
        external
    {   
        require(_tokenVote.length == _weights.length, "GaugeProxy: token votes count does not match weights count");
        _updateCurrentId();
        _vote(msg.sender, _tokenVote, _weights);
        delegations[msg.sender].blockDelegate[currentId] = true;
    }

    function setVotingDelegate(
        address _delegateAddress,
        uint256 _periodsCount,
        bool _indefinite
    ) external {
        require(
            _delegateAddress != address(0),
            "GaugeProxyV2: cannot delegate zero address"
        );
        require(
            _delegateAddress != msg.sender,
            "GaugeProxyV2: delegate address cannot be delegating"
        );

        delegateData storage _delegate = delegations[msg.sender];

        uint256 actualCurrentPeriodId = getActualCurrentPeriodId();

        address currentDelegate = _delegate.delegate;
        _delegate.delegate = _delegateAddress;
        _delegate.prevDelegate = currentDelegate;
        _delegate.updatePeriodId = actualCurrentPeriodId;

        if (_indefinite == true) {
            _delegate.indefinite = true;
        } else {
            _delegate.endPeriod = actualCurrentPeriodId + _periodsCount;
        }
    }

    function voteFor(
        address _owner,
        address[] calldata _tokenVote,
        int256[] calldata _weights
    ) external {
        require(_tokenVote.length == _weights.length,"GaugeProxy: token votes count does not match weights count");
        _updateCurrentId();
        delegateData storage _delegate = delegations[_owner];
        require(
            (_delegate.delegate == msg.sender &&
                currentId > _delegate.updatePeriodId) ||
                (_delegate.prevDelegate == msg.sender &&
                    currentId == _delegate.updatePeriodId),
            "Sender not authorized"
        );
        require(
            _delegate.blockDelegate[currentId] == false,
            "Delegating address has already voted"
        );
        require(
            _delegate.indefinite == true || _delegate.endPeriod <= currentId,
            "Delegating period expired"
        );

        _vote(_owner, _tokenVote, _weights);
    }

    // Add new token gauge
    function addGauge(address _token) external {
        require(msg.sender == governance, "!gov");
        require(gauges[_token] == address(0x0), "exists");
        gauges[_token] = address(new Gauge(_token));
        _tokens.push(_token);
    }

    function delistGauge(address _token) external {
        require(msg.sender == governance, "!gov");
        require(gauges[_token] != address(0x0), "!exists");

        uint256 _actualCurrentId = getActualCurrentPeriodId();
        require(
            prevDistributionId == _actualCurrentId - 1,
            "! all distributions completed"
        );

        address _gauge = gauges[_token];

        require(gaugeWithNegativeWeight[_gauge] >= 5, "censors < 5");

        delete gauges[_token];

        // address[] storage newTokenArray = new address[]();
        uint256 tokensLength = _tokens.length;

        for (uint256 i = 0; i < tokensLength; i++) {
            if (_tokens[i] != _token) _tokensTemp.push(_tokens[i]);
        }
        _tokens = _tokensTemp;
    }

    // Sets MasterChef PID
    function setPID(uint256 _pid) external {
        require(msg.sender == governance, "!gov");
        require(pid == 0, "pid has already been set");
        require(_pid > 0, "invalid pid");
        pid = _pid;
    }

    // Deposits mDILL into MasterChef
    function deposit() public {
        require(pid > 0, "pid not initialized");
        IERC20 _token = TOKEN;
        uint256 _balance = _token.balanceOf(address(this));
        _token.safeApprove(address(MASTER), 0);
        _token.safeApprove(address(MASTER), _balance);
        MASTER.deposit(pid, _balance);
    }

    // Fetches Pickle
    function collect() public {
        (uint256 _locked, ) = MASTER.userInfo(pid, address(this));
        MASTER.withdraw(pid, _locked);
        deposit();
    }

    function length() external view returns (uint256) {
        return _tokens.length;
    }

    function distribute(uint256 _start, uint256 _end) external {
        require(_start < _end, "GaugeProxyV2: bad _start");
        require(_end <= _tokens.length, "GaugeProxyV2: bad _end");
        require(
            msg.sender == governance,
            "GaugeProxyV2: only governance can distribute"
        );

        _updateCurrentId();

        require(
            prevDistributionId < currentId - 1,
            "GaugeProxyV2: all period distributions complete"
        );

        collect();
        int256 _balance = int256(PICKLE.balanceOf(address(this)));
        int256 _totalWeight = totalWeight[prevDistributionId + 1];
        if (_balance > 0 && _totalWeight > 0) {
            for (uint256 i = _start; i < _end; i++) {
                address _token = _tokens[i];
                address _gauge = gauges[_token];
                uint256 _reward = uint256(
                    _balance * (weights[_token][prevDistributionId + 1]) / (_totalWeight)
                );
                if (_reward > 0) {
                    PICKLE.safeApprove(_gauge, 0);
                    PICKLE.safeApprove(_gauge, _reward);
                    Gauge(_gauge).notifyRewardAmount(_reward);
                }

                if (_reward < 0) {
                    gaugeWithNegativeWeight[_gauge] += 1;
                }
            }
        }

        if (_tokens.length == _end) {
            prevDistributionId += 1;
        }
    }
}