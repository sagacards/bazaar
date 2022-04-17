import { assert } from "chai";
import { admin, users } from "./accounts";
import { getAccountIdentifier } from "../lib/keys";

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
