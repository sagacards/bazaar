import { assert } from "chai";
import { nftPrincipal } from "../lib";
import { MintError, Error } from "../lib/declarations/bazaar/bazaar.did.d";
import { admin, mint, users } from "./accounts";
import { eventData } from "./events.test";
import { isOk } from "./utils/result";

describe("Holders", () => {
    const user = users[0];

    before(async () => {
        await mint(user, 100_00_000_000n);

        let i = await admin.nft.launchpadEventCreate({
            ...eventData,
            accessType: {
                "Holders": {
                    canisters: [nftPrincipal],
                    allowType: { "Unlimited": null }
                }
            }
        });
        assert.equal(i, 0n);
    });
    after(async () => {
        await admin.ledger.reset();
        await admin.nft.reset(100n);
        await admin.launchpad.removeEvent(nftPrincipal, 0n);
    });

    it("Try to mint an NFT...", async () => {
        const result = await user.launchpad.mint(nftPrincipal, 0n);
        assert.isTrue("err" in result);
        const err = (<{ "err": MintError }>result).err;
        assert.isTrue("Events" in err);
        const eErr = (<{ "Events": Error }>err).Events;
        assert.isTrue("NotInAllowlist" in eErr);
    });
    it("Try to mint as an NFT owner.", async () => {
        await admin.nft.launchpadMint(user.principal);
        const tokenIndex = isOk(await user.launchpad.mint(nftPrincipal, 0n));
        assert.equal(tokenIndex, 1n);
    });
});
