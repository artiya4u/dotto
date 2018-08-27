pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract Dotto is Ownable {
  bool public canJoin;
  uint256 public fee;
  uint256 public prize;
  mapping(address => Submission) public submissions;
  mapping(bytes32 => address) public pickedNumberHashes;
  address[] public validParticipant;
  uint32 public round;

  struct Submission {
    uint256 pickedNumber;
    bytes32 pickedNumberHash;
  }

  constructor() public {
    fee = 0;
    prize = 0;
    canJoin = false;
  }

  event Hash(bytes32 hash1, bytes32 hash2);

  function openJoin(uint256 _fee, uint256 _prize) onlyOwner external {
    require(!canJoin);
    fee = _fee;
    prize = _prize;
    canJoin = true;
    round++;
  }

  function closeJoin() onlyOwner external {
    require(canJoin);
    canJoin = false;
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

  function join(bytes32 pickedNumberHash) payable external {
    require(canJoin);
    require(msg.value == fee);
    require(pickedNumberHashes[pickedNumberHash] == address(0));
    pickedNumberHashes[pickedNumberHash] = msg.sender;
    submissions[msg.sender] = Submission({
      pickedNumber : 0,
      pickedNumberHash : pickedNumberHash
      });
  }

  function reveal(uint256 _pickedNumber) external {
    require(!canJoin);
    Submission storage sub = submissions[msg.sender];
    sub.pickedNumber = _pickedNumber;
    require(_isValidNumber(sub));
    validParticipant.push(msg.sender);
  }

  function _isValidNumber(Submission sub)
  internal
  constant
  returns (bool)
  {
    bytes32 hash = keccak256(bytes32(sub.pickedNumber));
    emit Hash(sub.pickedNumberHash, hash);
    return sub.pickedNumberHash == hash;
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