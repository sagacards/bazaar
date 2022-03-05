import Blob "mo:base/Blob";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Principal "mo:base/Principal";

import Account "Account";
import Ledger "Ledger";

shared({caller}) actor class Rex(
    LEDGER_ID : Text,
) = this {
    /// 🧪 e2e tests.
    let version = 1;

    private let ledger : Ledger.Interface = actor(LEDGER_ID);

    /// List of admins.
    private stable var admins : List.List<Principal> = ?(caller, null);

    private let locked = HashMap.HashMap<Principal, Nat64>(0, Principal.equal, Principal.hash);

    // 1 ICP = 1_00_000_000 (e8s).
    private stable var price : Nat64 = 1_00000000;

    /// 🛑 @modifier
    private func isAdmin(caller : Principal) {
        assert(List.find(admins, func (p : Principal) : Bool { p == caller }) != null);
    };

    /// 🛑
    public shared({caller}) func addAdmin(a : Principal) {
        isAdmin(caller);
        admins := ?(a, admins);
    };

    /// 🛑
    public shared({caller}) func removeAdmin(a : Principal) {
        isAdmin(caller);
        admins := List.filter(admins, func (p : Principal) : Bool { p != a });
    };

    /// 🛑
    public query({caller}) func getAdmins() : async [Principal] {
        isAdmin(caller);
        List.toArray(admins);
    };

    /// 🛑
    public shared({caller}) func setPrice(e8s: Nat64) {
        isAdmin(caller);
        price := e8s;
    };

    /// 🛑
    public shared({caller}) func unlockAccountBalance(p : Principal, amount: ?Nat64) {
        isAdmin(caller);
        switch (locked.get(p)) {
            case (? e8s) {
                let a = switch (amount) {
                    case (? a)  a;
                    case (null) e8s;
                };
                if (e8s <= a) { locked.delete(p) } else { locked.put(p, e8s - a) };
            };
            case (null) {};
        };
    };

    public query func getPrice() : async Nat64 { price };

    public query({caller}) func getPersonalAccount() : async Account.Account {
        personalAccountOfPrincipal(caller);
    };

    private func personalAccountOfPrincipal(p : Principal) : Account.Account {
        Account.getAccount(Principal.fromActor(this), p);
    };

    public shared({caller}) func balance() : async Ledger.Tokens {
        await ledger.account_balance({
            account = personalAccountOfPrincipal(caller);
        });
    };

    public query({caller}) func lockedBalance() : async Ledger.Tokens {
        switch (locked.get(caller)) {
            case (? e8s) return { e8s };
            case (null)  return { e8s = 0 };
        };
    };

    public shared({caller}) func lockBalance() : async Ledger.TransferResult {
        switch (locked.get(caller)) {
            case (? _)  assert(false);
            case (null) {};
        };
        let result = await ledger.transfer({
            memo            = 0;
            amount          = { e8s = price };
            fee             = { e8s = 10_000 };
            from_subaccount = ?Blob.fromArray(Account.principal2SubAccount(caller));
            to              = Account.zeroAccount(Principal.fromActor(this));
            created_at_time = null;
        });
        switch (result) {
            case (#Ok(_)) locked.put(caller, price);
            case (_)      {};
        };
        return result;
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
