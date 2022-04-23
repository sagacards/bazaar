import { assert } from "chai";
import { nftPrincipal } from "../lib";
import { Allowlist } from "../lib/declarations/bazaar/bazaar.did.d";
import { admin, mintAll, users } from "./accounts";
import { isOk } from "./utils/result";
import { eventData } from "./events.test";

const spots : Allowlist = [
    [users[0].principal, [-1n]],
    [users[1].principal, [2n]],
    [users[2].principal, [0n]],
    [users[3].principal, []]
];

describe("Private Event", () => {
    before(async () => {
        await mintAll(users, 100_00_000_000n);
        let i = await admin.nft.launchpadEventCreate({
            ...eventData,
            accessType: { "Private": spots }
        });
        assert.equal(i, 0n);
    });
    after(async () => {
        await admin.ledger.reset();
        await admin.nft.reset(100n);
        await admin.launchpad.removeEvent(nftPrincipal, 0n);
    });

    it("Check if user0 has unlimited spots.", async () => {
        const user = users[0];
        let result = isOk(await user.launchpad.getAllowlistSpots(nftPrincipal, 0n));
        assert.equal(result, -1n);
    });
    it("Check if user1 has 2 spots.", async () => {
        const user = users[1];
        let result = isOk(await user.launchpad.getAllowlistSpots(nftPrincipal, 0n));
        assert.equal(result, 2n);
    });
    it("Check if others have no spots.", async () => {
        for (let i = 2; i < 4; i++) {
            const user = users[i];
            let result = isOk(await user.launchpad.getAllowlistSpots(nftPrincipal, 0n));
            assert.equal(result, 0n);
        };
    });
    it("Mint 2 NFTs as user1.", async () => {
        const user = users[1];
        await user.launchpad.mint(nftPrincipal, 0n);
        await user.launchpad.mint(nftPrincipal, 0n);
    });
    it("Check if user1 has no spots left.", async () => {
        const user = users[1];
        let result = isOk(await user.launchpad.getAllowlistSpots(nftPrincipal, 0n));
        assert.equal(result, 0n);
    });
});