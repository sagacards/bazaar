import { assert } from "chai";
import { admin, users } from "./accounts";
import { getAccountIdentifier } from "../lib/keys";


describe("Ledger", () => {
    const user = users[0];
    after(async () => {
        await admin.ledger.reset();
    });

    it("Mint TICP for user0.", async () => {
        const account = await user.launchpad.getPersonalAccount();
        await admin.ledger.mint({
            to: account,
            amount: { e8s: 100_00_000_000n }
        });
        const balance = await user.ledger.account_balance({ account });
        assert.equal(balance.e8s, 100_00_000_000n);
    });
    it("Check users0 balance through launchpad.", async () => {
        const balance = await users[0].launchpad.balance();
        assert.equal(balance.e8s, 100_00_000_000n);
    });
    it("Withdraw half of the balance.", async () => {
        const zeroAccount = getAccountIdentifier(users[0].key.getPrincipal());
        const half = 5_000_000_000n - 10_000n;
        await users[0].launchpad.transfer(
            { e8s: half },
            zeroAccount,
        );
        const balance = await user.launchpad.balance();
        assert.equal(balance.e8s, 5_000_000_000n);
    });
});
