import 'dotenv/config';
import { assert } from "chai";
import { nftPrincipal } from "../lib";
import { Allowlist, MintError, MintResult } from "../lib/declarations/bazaar/bazaar.did.d";
import { admin, mintAll, users } from "./accounts";

const time = BigInt(Date.now()) * 1_000_000n;
const spots: Allowlist = users.map((user) => [user.principal, [2n]]);
const eventData = {
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
    accessType: { "Private": spots },
    price: { "e8s": 1_00_000_000n },
};

describe("Minting Chaos", () => {
    if (!process.env.CHAOS) return;

    before(async () => {
        await mintAll(users, 100_00_000_000n);
        await admin.nft.reset(25n);
        let i = await admin.nft.launchpadEventCreate(eventData);
        assert.equal(i, 0n);
    });
    after(async () => {
        await admin.ledger.reset();
        await admin.nft.reset(100n);
        await admin.launchpad.removeEvent(nftPrincipal, 0n);
    });

    it("Chaos", async () => {
        for (let i = 0; i < 10; i++) {
            let batch = [];
            for (const user of users) batch.push(user.launchpad.mint(nftPrincipal, 0n));
            for (let i = 0; i < batch.length; i++) {
                const b : MintResult = await batch[i];
                if ("err" in b) {
                    const err = (<{ 'err': MintError }>b).err;
                    console.log(err);
                };
                if ("ok" in b) {
                    const tokenId = (<{ 'ok': bigint}>b).ok;
                    console.log(tokenId);
                };
            };
        };
    });
});