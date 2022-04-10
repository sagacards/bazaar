import { Ed25519KeyIdentity } from "@dfinity/identity";
import { Principal } from "@dfinity/principal";
import { assert } from "chai";
import { launchpadActor, mockLedgerActor } from "../lib";
import { fetchIdentity, getAccountIdentifier } from "../lib/keys";

const users = new Array(2).fill(Ed25519KeyIdentity.generate()).map((k) => {
    return {
        key: k,
        launchpad: launchpadActor(k),
        ledger: mockLedgerActor(k),
    }
});

const adminKey = fetchIdentity("admin");
const admin = {
    key: fetchIdentity("admin"),
    launchpad: launchpadActor(adminKey),
    ledger: mockLedgerActor(adminKey)
}

describe("Ledger", () => {
    it("Mint TICP for user0.", async () => {
        const account = await users[0].launchpad.getPersonalAccount();
        await admin.ledger.mint({
            to: account,
            amount: { e8s: 10000000000n }
        });
        const balance = await users[0].ledger.account_balance({ account });
        assert.equal(balance.e8s, 10000000000n);
    });
    it("Check users0 balance through launchpad.", async () => {
        const balance = await users[0].launchpad.balance();
        assert.equal(balance.e8s, 10000000000n);
    });
    it("Withdraw half of the balance.", async () => {
        const zeroAccount = getAccountIdentifier(users[0].key.getPrincipal());
        const half = 5000000000n - 10000n;
        await users[0].launchpad.transfer(
            { e8s: half },
            zeroAccount,
        );
        const balance = await users[0].launchpad.balance();
        assert.equal(balance.e8s, 5000000000n);
    });
});
