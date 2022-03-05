import Blob "mo:base/Blob";
import List "mo:base/List";
import Principal "mo:base/Principal";

import Account "Account";
import Ledger "Ledger";

shared({caller}) actor class Rex(
    LEDGER_ID : Text,
) = this {
    private let ledger : Ledger.Interface = actor(LEDGER_ID);

    private stable var admins : List.List<Principal> = ?(caller, null);

    /// @modifier
    private func isAdmin(caller : Principal) {
        assert(List.find(admins, func (p : Principal) : Bool { p == caller }) != null);
    };

    public shared({caller}) func addAdmin(a : Principal) {
        isAdmin(caller);
        admins := ?(a, admins);
    };

    public shared({caller}) func removeAdmin(a : Principal) {
        isAdmin(caller);
        admins := List.filter(admins, func (p : Principal) : Bool { p != a });
    };

    public query({caller}) func getAdmins() : async [Principal] {
        isAdmin(caller);
        List.toArray(admins);
    };

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
