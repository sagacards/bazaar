import Blob "mo:base/Blob";
import Principal "mo:base/Principal";

import Account "Account";
import Ledger "Ledger";

actor class Rex(
    LEDGER_ID : Text,
) = this {
    private let ledger : Ledger.Interface = actor(LEDGER_ID);

    public query({caller}) func getPersonalAccount() : async Text {
        Account.toText(personalAccountOfPrincipal(caller));
    };

    private func personalAccountOfPrincipal(p : Principal) : Blob {
        Account.getAccount(Principal.fromActor(this), p);
    };

    public shared({caller}) func balance() : async Nat64 {
        let { e8s } = await ledger.account_balance({
            account = personalAccountOfPrincipal(caller);
        });
        e8s;
    };

    public shared({caller}) func transfer(amount : Nat64, to : Text) : async Ledger.TransferResult {
        let accountId = switch(Account.fromText(to)) {
            case (#err(_)) {
                assert(false);
                loop {};
            };
            case (#ok(a)) a;
        };
        await ledger.transfer({
            memo            = 0;
            amount          = { e8s = amount };
            fee             = { e8s = 10_000 };
            from_subaccount = ?Blob.fromArray(Account.principal2SubAccount(caller));
            to              = accountId;
            created_at_time = null;
        });
    };
};
