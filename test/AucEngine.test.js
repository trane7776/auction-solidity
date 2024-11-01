const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('AucEngine', () => {
  let owner;
  let seller;
  let buyer;
  let auct;

  beforeEach(async () => {
    [owner, seller, buyer] = await ethers.getSigners();
    const AucEngine = await ethers.getContractFactory('AucEngine', owner);
    auct = await AucEngine.deploy();
    await auct.waitForDeployment();
  });

  it('sets owner', async () => {
    expect(await auct.owner()).to.equal(owner.address);
  });

  async function getTimestamp(bn) {
    return (await ethers.provider.getBlock(bn)).timestamp;
  }

  function delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  describe('createAuction', () => {
    it('creates an auction correctly', async () => {
      const duration = 60;
      const tx = await auct
        .connect(seller)
        .createAuction(ethers.parseEther('0.0001'), 3, 'fake item', duration);
      const cAuction = await auct.auctions(0);
      const timestamp = await getTimestamp(tx.blockNumber);
      expect(cAuction.seller).to.equal(seller.address);
      expect(cAuction.item).to.equal('fake item');
      expect(cAuction.endsAt).to.equal(timestamp + duration);
    });
  });

  describe('buy', () => {
    it('allows to buy', async () => {
      await auct
        .connect(seller)
        .createAuction(ethers.parseEther('0.0001'), 3, 'fake item', 60);
      this.timeout = 5000; // 5 seconds
      await delay(1000);
      const buyTx = await auct
        .connect(buyer)
        .buy(0, { value: ethers.parseEther('0.0001') });
      const cAuction = await auct.auctions(0);
      const finalPrice = cAuction.finalPrice;

      await expect(() => buyTx).to.changeEtherBalance(
        seller,
        finalPrice - (finalPrice * 10n) / 100n
      );

      await expect(buyTx)
        .to.emit(auct, 'AuctionEnded')
        .withArgs(0, finalPrice, buyer.address);

      await expect(
        auct.connect(buyer).buy(0, { value: ethers.parseEther('0.0001') })
      ).to.be.revertedWith('Auction stopped');
    });
  });
});
