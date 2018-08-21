pragma solidity ^0.4.18;

import "./Ownable.sol";

contract Dotto is Ownable {
  bool public isStarted;
  uint256 public fee;
  uint256 public prize;
  mapping(address => Submission) public submissions;
  address[] public validParticipant;

  struct Submission {
    uint8 pickedNumber;
    bytes32 pickedNumberHash;
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  function Dotto(){
    fee = 0;
    prize = 0;
    isStarted = false;
  }

  function startJoin(uint256 _fee, uint256 _prize) onlyOwner external {
    fee = _fee;
    prize = _prize;
    isStarted = true;
  }

  function startJoin() onlyOwner external {
    isStarted = false;
  }

  function distributePrize() onlyOwner external {
    uint256[] numbers;
    for (uint i = 0; i < validParticipant.length; i++) {
      numbers.push(submissions[validParticipant[i]].pickedNumber);

    }

    uint256 rand = xorAll(numbers);
    uint256 luckyIndex = rand % validParticipant.length;
    address luckyAddress = validParticipant[luckyIndex];
    luckyAddress.transfer(prize);
  }

  function join(
    bytes32 pickedNumberHash,
    uint8 v,
    bytes32 r,
    bytes32 s) payable external {
    submissions[msg.sender] = Submission({
      pickedNumber : 0,
      pickedNumberHash : pickedNumberHash,
      v : v,
      r : r,
      s : s
      });
    require(isStarted);
    require(msg.value == fee);
  }

  function reveal(uint64 pickedNumber) external {
    require(!isStarted);
    Submission storage sub = submissions[msg.sender];
    require(isValidNumber(pickedNumber, msg.sender, sub.pickedNumberHash, sub.v, sub.r, sub.s));
    validParticipant.push(msg.sender);
  }

  function isValidNumber(
    uint64 pickedNumber,
    address sender,
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s)
  public
  constant
  returns (bool)
  {
    return sender == ecrecover(
      keccak256(abi.encodePacked(pickedNumber, hash)),
      v,
      r,
      s
    );
  }

  function xorAll(uint256[] memory _data) public pure returns (uint256 o_sum) {
    assembly {
      let len := mload(_data)
      let data := add(_data, 0x20)

    // Iterate until the bound is not met.
      for
      {let end := add(data, mul(len, 0x20))}
      lt(data, end)
      {data := add(data, 0x20)}
      {
        o_sum := xor(o_sum, mload(data))
      }
    }
  }
}