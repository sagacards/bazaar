import { assert } from "chai";
import { admin, users } from "./accounts";
import { nftPrincipal } from "../lib";

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
    price: { "e8s": 1_00_000_000n },
};

describe("Events", () => {
    it("Check if no events exist.", async () => {
        const user = users[0];
        const events = await user.launchpad.getAllEvents();
        assert.equal(events.length, 0);
    });
    it("Try to create an event as a user.", async () => {
        const user = users[0];
        user.nft.launchpadEventCreate(eventData).then(() => assert.fail()).catch(/* OK */);
    });
    it("Create an event as an admin.", async () => {
        let i = await admin.nft.launchpadEventCreate(eventData);
        assert.equal(i, 0n);
    });
    it("Check if the created event exist.", async () => {
        const user = users[0];
        const events = await user.launchpad.getAllEvents();
        assert.equal(events.length, 1);
        const event = events[0];
        assert.equal(event[2], 0n);
    });
    it("Try to delete an event as a user.", async () => {
        const user = users[0];
        user.launchpad.removeEvent(nftPrincipal, 0n).then(() => assert.fail()).catch(/* OK */);
    });
    it("Delete the created event as an admin.", async () => {
        await admin.launchpad.removeEvent(nftPrincipal, 0n);
    });
});
