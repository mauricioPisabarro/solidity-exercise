import { expect, use } from "chai";
import { MockProvider, solidity, deployContract } from "ethereum-waffle";
import { BigNumberish, ContractTransaction, Event, Wallet } from "ethers";
import { Game, Game__factory } from "../typechain";

use(solidity);

describe("Game contract", function () {
  const [adminSigner, userSigner] = new MockProvider().getWallets();
  let gameContract: Game;

  beforeEach(async () => {
    gameContract = (await deployContract(
      adminSigner,
      Game__factory,
      []
    )) as Game;
  });

  it("transfers admin permissions to owner of contract", async function () {
    const ownerIsAdmin = await gameContract.isAdmin(adminSigner.address);

    expect(ownerIsAdmin).to.equal(true);
  });

  it("identifies other address as not admin", async function () {
    const otherWalletIsNotAdmin = await gameContract.isAdmin(
      userSigner.address
    );

    expect(otherWalletIsNotAdmin).to.equal(false);
  });

  it("only allows admin to create a boss", async function () {
    const gameFromPlayersPerspective = gameContract.connect(userSigner);
    const tx = gameFromPlayersPerspective.createBoss(10, 10, 10);

    await expect(tx).to.be.revertedWith("Only the admin can do this");

    const otherTx = gameContract.createBoss(10, 10, 10);
    await expect(otherTx).to.not.be.reverted;
  });

  it("only allows one character per user", async function () {
    const tx = gameContract.createCharacter();
    await expect(tx).not.to.be.revertedWith("Only one character per user");

    const otherTx = gameContract.createCharacter();
    await expect(otherTx).to.be.revertedWith("Only one character per user");
  });

  it("revert populate boss if it does not exist", async function () {
    const tx = gameContract.populateBoss(3);
    await expect(tx).to.be.revertedWith("Boss does not exist");
  });

  it("revert populate boss if current boss is not defeated", async function () {
    const tx = gameContract.createBoss(10, 10, 10);
    await expect(tx).to.not.be.reverted;

    const oneTx = gameContract.populateBoss(0);
    await expect(oneTx).to.not.be.reverted;

    const otherTx = gameContract.createBoss(10, 10, 10);
    await expect(otherTx).to.not.be.reverted;

    const anotherTx = gameContract.populateBoss(1);
    await expect(anotherTx).to.be.revertedWith("Current boss to be defeated");
  });

  it("emits populate boss event", async function () {
    const tx = gameContract.createBoss(10, 10, 10);
    await expect(tx).to.not.be.reverted;

    const oneTx = await gameContract.populateBoss(0);
    await expect(oneTx).to.emit(gameContract, "BossPopulated");
  });

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
  });

  it("gets existing boss", async function () {
    const tx = await gameContract.createBoss(10, 10, 10);
    const bossId = await getCreatedBossId(tx);

    const boss = await gameContract.getBoss(bossId);
    expect(boss).to.not.be.null;
  });

  it("gets existing character", async function () {
    const tx = await gameContract.createCharacter();
    const characterId: BigNumberish = await getCreatedCharacterId(tx);

    const character = await gameContract.getCharacter(characterId);
    expect(character).to.not.be.null;
  });

  it("prevents unexperienced users from healing", async function () {
    const { userOwnedCharacterId } = await getCharactersAndBoss(
      gameContract,
      userSigner
    );

    const gameFromPlayersPerspective = gameContract.connect(userSigner);
    const tx = gameFromPlayersPerspective.heal(userOwnedCharacterId);

    await expect(tx).to.be.revertedWith("You need a character with XP");
  });

  it("prevents from healing themselves", async function () {
    const { adminOwnedCharacterId } = await getCharactersAndBoss(gameContract, userSigner);

    await (await gameContract.attackBoss()).wait();

    const tx = gameContract.heal(adminOwnedCharacterId);
    await expect(tx).to.be.revertedWith("You cannot heal yourself");
  });
});

async function getCharactersAndBoss(gameContract: Game, userSigner: Wallet) {
  const tx = await gameContract.createCharacter();
  const adminOwnedCharacterId: BigNumberish = await getCreatedCharacterId(tx);

  const gameFromPlayersPerspective = gameContract.connect(userSigner);
  const anotherTx = await gameFromPlayersPerspective.createCharacter();
  const userOwnedCharacterId = await getCreatedCharacterId(anotherTx);

  const txBoss = await gameContract.createBoss(100, 10, 1);
  const bossId = await getCreatedBossId(txBoss);

  const populateBossTx = await gameContract.populateBoss(bossId);
  await populateBossTx.wait();

  return { adminOwnedCharacterId, userOwnedCharacterId, bossId };
}

async function getCreatedCharacterId(tx: ContractTransaction): Promise<BigNumberish> {
  const txReceipt = await tx.wait();
    const createdCharacter: Event = txReceipt.events?.find(
      (event) => event.event === "CharacterCreated"
    ) as Event;
    const { characterId } = createdCharacter.args as any;

    return characterId;
}

async function getCreatedBossId(tx: ContractTransaction): Promise<BigNumberish> {
  const txReceipt = await tx.wait();
    const createdBoss: Event = txReceipt.events?.find(
      (event) => event.event === "BossCreated"
    ) as Event;
    const { bossId } = createdBoss.args as any;

    return bossId;
}
