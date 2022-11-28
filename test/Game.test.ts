import { expect, use } from "chai";
import { MockProvider, solidity, deployContract } from "ethereum-waffle";
import { Game, Game__factory } from "../typechain";

use(solidity);

describe("Game contract", function () {
  const [adminSigner, userSigner] = new MockProvider().getWallets();
  let gameContract: Game;

  beforeEach(async () => {
    gameContract = await deployContract(adminSigner, Game__factory, []) as Game;
  });

  it("transfers admin permissions to owner of contract", async function () {
    const ownerIsAdmin = await gameContract.isAdmin(adminSigner.address);

    expect(ownerIsAdmin).to.equal(true);
  });

  it("identifies other address as not admin", async function () {
    const otherWalletIsNotAdmin = await gameContract.isAdmin(userSigner.address);
      
    expect(otherWalletIsNotAdmin).to.equal(false);
  })

  it("only allows admin to create a boss", async function () {
    const gameFromPlayersPerspective = gameContract.connect(userSigner);
    const tx = gameFromPlayersPerspective.createBoss(10, 10, 10)

    await expect(tx).to.be.revertedWith("Only the admin can do this");

    const otherTx = gameContract.createBoss(10, 10, 10);
    await expect(otherTx).to.not.be.reverted;
  })

  it("only allows one character per user", async function () {
    const tx = gameContract.createCharacter()
    await expect(tx).not.to.be.revertedWith("Only one character per user");

    const otherTx = gameContract.createCharacter()
    await expect(otherTx).to.be.revertedWith("Only one character per user");
  })


  it("revert populate boss if it does not exist", async function () {
    const tx = gameContract.populateBoss(3);
    await expect(tx).to.be.revertedWith("Boss does not exist");
  })

  it("revert populate boss if current boss is not defeated", async function () {
    const tx = gameContract.createBoss(10, 10, 10);
    await expect(tx).to.not.be.reverted;

    const oneTx = gameContract.populateBoss(0);    
    await expect(oneTx).to.not.be.reverted;

    const otherTx = gameContract.createBoss(10, 10, 10);
    await expect(otherTx).to.not.be.reverted;

    const anotherTx = gameContract.populateBoss(1);
    await expect(anotherTx).to.be.revertedWith("Current boss to be defeated");
  })

  it("emits event on boss defeat", async function () {
    // Creating weak boss
    const tx = gameContract.createBoss(1, 10, 10);
    await expect(tx).to.not.be.reverted;
    const oneTx = gameContract.populateBoss(0);    
    await expect(oneTx).to.not.be.reverted;

    const gameFromPlayersPerspective = gameContract.connect(userSigner);
    const otherTx = gameFromPlayersPerspective.createCharacter();
    await expect(otherTx).to.not.be.reverted;

    const anotherTx = gameFromPlayersPerspective.attackBoss();
    await expect(anotherTx).to.emit(gameContract, "BossDefeated");
  })
});