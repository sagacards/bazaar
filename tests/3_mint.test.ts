import { assert } from "chai";
import { nftPrincipal } from "../lib";
import { eventData } from "./2_events.test";
import { admin, users } from "./accounts";

describe("Mint", () => {
    it("Create an event as an admin.", async () => {
        let i = await admin.nft.launchpadEventCreate(eventData);
        assert.equal(i, 0n);
    });
    it("Get events.", async () => {
        const user = users[0];
        const events = await user.launchpad.getEventsOfToken(nftPrincipal);
        assert.equal(events.length, 1);
        const event = events[0];
        const price = event.price;
        assert.equal(price.e8s, 1_00_000_000n);
    });
    it("Mint an NFT...", async () => {
        const user = users[0];
        const tokenIndex = await user.launchpad.mint(nftPrincipal, 0n);
        assert.isTrue("ok" in tokenIndex);
        assert.equal((<{ "ok": bigint }>tokenIndex).ok, 0n);
        const balance = await user.nft.balance();
        assert.equal(balance.length, 1);
        assert.equal(balance[0], 0n);
    });
    it("Check balances after mint.", async () => {
        const user = users[0];
        const account = await user.launchpad.getPersonalAccount();
        const balance = await user.ledger.account_balance({ account });
        assert.equal(balance.e8s, 4_899_990_000n);

        const nftAccount = await user.nft.getPersonalAccount();
        const nftBalance = await user.ledger.account_balance({ account: nftAccount });
        assert.equal(nftBalance.e8s, 1_00_000_000n)
    });
    it("Mint, but NFT traps.", async () => {
        await admin.nft.toggleTrap(true);
        const user = users[0];
        const err = await user.launchpad.mint(nftPrincipal, 0n);
        assert.isTrue("err" in err);
        assert.isTrue("Refunded" in (<{ "err": object }>err).err)
    });
    it("Check whether price was refunded...", async () => {
        const user = users[0];
        const account = await user.launchpad.getPersonalAccount();
        const balance = await user.ledger.account_balance({ account });
        assert.equal(balance.e8s, 4_899_990_000n);
        const minting = await user.launchpad.currentlyMinting();
        assert.equal(minting, 0n);
    });
});
