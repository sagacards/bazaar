import { assert } from "chai";
import { nftPrincipal } from "../lib";
import { admin, mint, users } from "./accounts";

const time = BigInt(Date.now());
export const eventData = {
    startsAt: time,
    endsAt: time * 2n,
    name: "test1",
    description: "",
    details: {
        descriptionMarkdownUrl: "",
        iconImageUrl: "",
        bannerImageUrl: "",
        previewImageUrl: "",
    },
    accessType: { "Public": null },
    price: { "e8s": 0n },
};


describe("Free", () => {
    const user = users[0];

    before(async () => {
        await mint(user, 100_00_000_000n);

        let i = await admin.nft.launchpadEventCreate(eventData);
        assert.equal(i, 0n);
    });
    after(async () => {
        await admin.ledger.reset();
        await admin.nft.reset(100n);
        await admin.launchpad.removeEvent(nftPrincipal, 0n);
    });

    it("Mint an NFT...", async () => {
        const tokenIndex = await user.launchpad.mint(nftPrincipal, 0n);
        assert.isTrue("ok" in tokenIndex);
        assert.equal((<{ "ok": bigint }>tokenIndex).ok, 0n);
        const balance = await user.nft.balance();
        assert.equal(balance.length, 1);
        assert.equal(balance[0], 0n);
    });
    it("Check balances after mint.", async () => {
        const account = await user.launchpad.getPersonalAccount();
        const balance = await user.ledger.account_balance({ account });
        assert.equal(balance.e8s, 100_00_000_000n);

        const nftAccount = await user.nft.getPersonalAccount();
        const nftBalance = await user.ledger.account_balance({ account: nftAccount });
        assert.equal(nftBalance.e8s, 0n);
    });
});
