import ether from "../helpers/ether";

const BigNumber = web3.BigNumber;
require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

const Dotto = artifacts.require('Dotto');

contract('Dotto', function ([owner, player1, player2, player3, player4]) {

  beforeEach(async function () {
    this.dotto = await Dotto.new();
  });

  it('can start new round', async function () {
    await this.dotto.openJoin(ether(1), ether(10), {from: owner});
    let play1 = '1000000000000000001';
    let play2 = '1000000000000000002';
    let play3 = '1000000000000000003';
    let play4 = '1000000000000000004';
    let play1Hash = web3.sha3(play1);
    let play2Hash = web3.sha3(play2);
    let play3Hash = web3.sha3(play3);
    let play4Hash = web3.sha3(play4);
    await this.dotto.join(play1Hash, {from: player1, value: ether(1)});
    await this.dotto.join(play2Hash, {from: player2, value: ether(1)});
    await this.dotto.join(play3Hash, {from: player3, value: ether(1)});
    await this.dotto.join(play4Hash, {from: player4, value: ether(1)});
    await this.dotto.closeJoin({from: owner});
    console.log('closed');
    await this.dotto.reveal(ether(play1), {from: player1});
    await this.dotto.reveal(ether(play2), {from: player2});
    await this.dotto.reveal(ether(play3), {from: player3});
    await this.dotto.reveal(ether(play4), {from: player4});
    console.log('revealed');
    await this.dotto.distributePrize({from: owner});
  });

});
