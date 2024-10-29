const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('LoggerInterface', () => {
  let owner;
  let demo;

  beforeEach(async function () {
    [owner] = await ethers.getSigners();

    const Logger = await ethers.getContractFactory('Logger', owner);
    const logger = await Logger.deploy();

    await logger.waitForDeployment();

    const Demo = await ethers.getContractFactory('Demo', owner);
    demo = await Demo.deploy(logger.target);

    await demo.waitForDeployment();
  });

  it('allows to pay and get payment info', async function () {
    const sum = 100;
    const txData = {
      value: sum,
      to: demo.target,
    };

    const tx = await owner.sendTransaction(txData);
    await tx.wait();

    await expect(tx).to.changeEtherBalance(demo, sum);

    const amount = await demo.payment(owner.address, 0);

    expect(amount).to.equal(sum);
  });
});
