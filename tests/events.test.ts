import { Ed25519KeyIdentity } from "@dfinity/identity";
import { assert } from "chai";
import { launchpadActor, mockLedgerActor } from "../lib";
import { fetchIdentity } from "../lib/keys";

const userKey = Ed25519KeyIdentity.generate();
const user = {
    key: userKey,
    launchpad: launchpadActor(userKey),
    ledger: mockLedgerActor(userKey),
}

const adminKey = fetchIdentity("admin");
const admin = {
    key: fetchIdentity("admin"),
    launchpad: launchpadActor(adminKey),
    ledger: mockLedgerActor(adminKey)
}

describe("Events", () => {
    it("Mint Test ICP for account...", async () => {
        const account = await user.launchpad.getPersonalAccount();
        await admin.ledger.mint({
            to: account,
            amount: { e8s: 10000000000n }
        });
        const balance = await user.ledger.account_balance({ account });
        assert.equal(balance.e8s, 10000000000n);
    });
});
