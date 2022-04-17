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
    });
});
