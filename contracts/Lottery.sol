pragma solidity 0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase, Ownable {
    address payable[] public players;
    address payable public recentWinner;
    uint256 public randomness;
    uint256 public usdEntryFee;
    AggregatorV3Interface internal ethUsdPriceFeed;
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }
    LOTTERY_STATE public Lottery_state;
    uint256 public fee;
    bytes32 public keyhash;
    event RequestedRandomness(bytes32 requestId);

    // 0 
    // 1
    // 2


    constructor(
        address _priceFeedAddress,
        address _vrfCoordinator,
        address _link,
        uint256 _fee,
        bytes32 _keyhash
    ) public VRFConsumerBase(_vrfCoordinator, _link) {
            usdEntryFee = 50 * (10**18);
            ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
            Lottery_state = LOTTERY_STATE.CLOSED;
            fee = _fee;
            keyhash = _keyhash;
    }
    function enter() public payable {
        require(Lottery_state == LOTTERY_STATE.OPEN);
        require(msg.value >= getEntryFee()," not enough Ether!");
        players.push(payable(msg.sender));
    }
    function getEntryFee() public view returns(uint256){
        (, int256 price, , ,) = ethUsdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10 ** 10; //18 decimals since 
        // 50, $1300 / Eth
        // 50/1300
        // 50 * 100000 / 1300
        uint256 costToEnter = (usdEntryFee * 10**18) / adjustedPrice;
        return costToEnter;
    }

    function startLottery() public onlyOwner {
        require(
        Lottery_state == LOTTERY_STATE.CLOSED,
        "can not start a new lottery yet!"
        );
        Lottery_state == LOTTERY_STATE.OPEN;
    }


    function endLottery() public onlyOwner {
        Lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        bytes32 requestId = requestRandomness(keyhash, fee);
        emit RequestedRandomness(requestId);
    }
    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
    internal 
    override
{
    require(
        Lottery_state == LOTTERY_STATE.CALCULATING_WINNER,
        "Not there yet!"
    );
    require(_randomness > 0, "random-not-found");
    uint256 indexOfWinner = _randomness % players.length;
    recentWinner = players[indexOfWinner];
    recentWinner.transfer(address(this).balance);
    //RESET
    players = new address payable[](0);
    Lottery_state = LOTTERY_STATE.CLOSED;
    randomness = _randomness;
}

    
}