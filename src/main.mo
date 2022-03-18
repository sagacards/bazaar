import Blob "mo:base/Blob";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Principal "mo:base/Principal";

import Account "Account";
import Interface "Interface";
import Ledger "Ledger";

shared({caller}) actor class Rex(
    LEDGER_ID : Text,
    NFT_ID    : Text,
) : async Interface.Interface = this {
    private let ledger : Ledger.Interface = actor(LEDGER_ID);
    private let nft : Interface.DIP721Interface = actor(NFT_ID);

    /// List of admins.
    private stable var admins : List.List<Principal> = ?(caller, null);

    // 1 ICP = 1_00_000_000 (e8s).
    private stable var price : Ledger.Tokens = { e8s = 1_00000000 };
    private stable var availableTokens : [Nat] = [];

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
    public shared({caller}) func setPrice(e8s : Ledger.Tokens) {
        isAdmin(caller);
        price := e8s;
    };

    /// 🛑
    public shared({caller}) func syncAvailableTokens() {
        switch (await nft.ownerTokenIds(Principal.fromActor(this))) {
            case (#Ok(tokenIds)) availableTokens := tokenIds;
            case (_) assert(false);
        };
    };

    public query func getPrice() : async Ledger.Tokens { price };

    public query({caller}) func getPersonalAccount() : async Ledger.AccountIdentifier {
        personalAccountOfPrincipal(caller);
    };

    private func personalAccountOfPrincipal(p : Principal) : Ledger.AccountIdentifier {
        Account.getAccount(Principal.fromActor(this), p);
    };

    public shared({caller}) func balance() : async Ledger.Tokens {
        await ledger.account_balance({
            account = personalAccountOfPrincipal(caller);
        });
    };

    public shared({caller}) func transfer(amount : Ledger.Tokens, to : Ledger.AccountIdentifier) : async Ledger.TransferResult {
        await ledger.transfer({
            memo            = 0;
            amount;
            fee             = { e8s = 10_000 };
            from_subaccount = ?Blob.fromArray(Account.principal2SubAccount(caller));
            to;
            created_at_time = null;
        });
    };
};
