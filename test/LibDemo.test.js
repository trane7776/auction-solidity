const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('LibDemo', () => {
  let owner;
  let demo;

  beforeEach(async function () {
    [owner] = await ethers.getSigners();

    const LibDemo = await ethers.getContractFactory('LibDemo', owner);
    demo = await LibDemo.deploy();

    await demo.waitForDeployment();
  });

  it('compare strings', async () => {
    let result = await demo.runnerStr('cat', 'cat');
    expect(result).to.eq(true);
    result = await demo.runnerStr('cat', 'cats');
    expect(result).to.eq(false);
  });

  it('finds uint in array', async () => {
    const array = [1, 2, 4, 54, 5, 6];
    let result = await demo.runnerArr(array, 54);
    expect(result).to.eq(true);
    result = await demo.runnerArr(array, 43);
    expect(result).to.eq(false);
  });
});
