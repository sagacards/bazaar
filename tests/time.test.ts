import { assert } from "chai";
import { nftPrincipal } from "../lib";
import { eventData } from "./events.test";
import { admin, mint, users } from "./accounts";
import { MintError, Error } from "../lib/declarations/bazaar/bazaar.did.d";
import { isOk } from "./utils/result";

describe("Time", () => {
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
        await admin.launchpad.setTestTime([]);
    });

    it("Try to mint before start.", async () => {
        await admin.launchpad.setTestTime([eventData.startsAt - 1n]) // 1 nsec before start.

        const result = await user.launchpad.mint(nftPrincipal, 0n);
        assert.isTrue("err" in result);
        const err = (<{ "err": MintError }>result).err;
        assert.isTrue("Events" in err);
        const eErr = (<{ "Events": Error }>err).Events;
        assert.isTrue("NotStarted" in eErr);
        assert.equal((<{ "NotStarted": bigint }>eErr).NotStarted, 1n);
    });
    it("Mint during event.", async () => {
        await admin.launchpad.setTestTime([eventData.startsAt])

        const tokenIndex = isOk(await user.launchpad.mint(nftPrincipal, 0n));
        assert.equal(tokenIndex, 0n);
        const balance = await user.nft.balance();
        assert.equal(balance.length, 1);
        assert.equal(balance[0], 0n);
    });
    it("Try to mint after end.", async () => {
        await admin.launchpad.setTestTime([eventData.endsAt]) // The end of the event.

        const result = await user.launchpad.mint(nftPrincipal, 0n);
        assert.isTrue("err" in result);
        const err = (<{ "err": MintError }>result).err;
        assert.isTrue("Events" in err);
        const eErr = (<{ "Events": Error }>err).Events;
        assert.isTrue("AlreadyOver" in eErr);
        assert.equal((<{ "AlreadyOver": bigint }>eErr).AlreadyOver, 0n);
    });
});
