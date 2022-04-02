import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import AccountIdentifier "AccountIdentifier";
import Event "Launchpad/Event";
import Interface "Interface";
import Launchpad "Launchpad";
import Ledger "Ledger";
import NFT "Launchpad/NFT";

shared({caller}) actor class Rex(
    LEDGER_ID : Text,
) : async Interface.Main = this {
    private let ledger : Ledger.Interface = actor(LEDGER_ID);

    /// List of admins.
    private stable var admins : List.List<Principal> = ?(caller, null);

    // 1 ICP = 1_00_000_000 (e8s).
    private stable var price : Ledger.Tokens = { e8s = 1_00000000 };
    private stable var availableTokens : [Nat] = [];

    // 🛑 ADMIN

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

    // 🟢 PUBLIC

    public query({caller}) func getAllowlistSpots(canister : Principal, index : Nat) : async ?Int {
        spots(caller, canister, index);
    };

    private func spots(caller : Principal, canister : Principal, index : Nat) : ?Int {
        switch (lp.getEvent(canister, index)) {
            case (null) {
                assert(false); // invalid event.
                null;
            };
            case (? { accessType }) {
                switch (accessType) {
                    case (#Public) return ?-1;
                    case (#Private(list)) {
                        for ((p, v) in list.vals()) {
                            if (p == caller) return v;
                        };
                        null;
                    };
                };
            };
        };
    };

    public query func getPrice() : async Ledger.Tokens { price };

    public query({caller}) func getPersonalAccount() : async Ledger.AccountIdentifier {
        personalAccountOfPrincipal(caller);
    };

    private func personalAccountOfPrincipal(p : Principal) : Ledger.AccountIdentifier {
        AccountIdentifier.getAccount(Principal.fromActor(this), p);
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
            from_subaccount = ?Blob.fromArray(AccountIdentifier.principal2SubAccount(caller));
            to;
            created_at_time = null;
        });
    };

    private func buy(token : Principal, caller : Principal) : async Ledger.TransferResult {
        await ledger.transfer({
            memo            = 0;
            amount          = price;
            fee             = { e8s = 10_000 };
            from_subaccount = ?Blob.fromArray(AccountIdentifier.principal2SubAccount(caller));
            to              = AccountIdentifier.getAccount(Principal.fromActor(this), token);
            created_at_time = null;
        });
    };

    public shared({caller}) func mint(token : Principal, index : Nat) : async Nat {
        switch (spots(caller, token, index)) {
            case (null) assert(false);
            case (? v) if (v == 0) assert(false);
        };
        let t : NFT.Interface = actor(Principal.toText(token));
        let available = await t.launchpadTotalAvailable(index);
        assert(0 < available);
        switch (await buy(token, caller)) {
            case (#Ok(_))  {};
            case (#Err(_)) assert(false);
        };
        // NOTE: from this point onwards, the user has paid!
        let r = try (await t.launchpadMint(caller)) catch (_) {
            #err(#TryCatchTrap);
        };
        switch (r) {
            case (#err(_)) {
                // TODO: refund!
                assert(false); 0;
            };
            case (#ok(n)) {
                // TODO: lower allowlist entry!
                n;
            };
        };
    };

    // 🚀 LAUNCHPAD

    private let lp = Launchpad.Launchpad();

    private let createEventPrice = 1_000_000_000_000; // 1T;
    private let updateEventPrice = 0_500_000_000_000;

    private func chargeCycles(amount : Nat) : Bool {
        if (Cycles.available() < amount)        return false;
        if (Cycles.accept(amount) < amount) return false;
        true;
    };

    public shared({caller}) func createEvent(data : Event.Data) : async Nat {
        assert(chargeCycles(createEventPrice));
        lp.createEvent(caller, data);
    };

    public shared({caller}) func updateEvent(index : Nat, data : Event.Data) : async () {
        assert(chargeCycles(updateEventPrice));
        lp.updateEvent(caller, index, data);
    };

    public query func getEvent(token : Principal, index : Nat) : async ?Event.Data {
        lp.getEvent(token, index);
    };

    public query({caller}) func getOwnEvents() : async [Event.Data] {
        lp.getEventsOfToken(caller);
    };

    public query func getAllEvents() : async Event.Events {
        lp.getAllEvents();
    };

    public query func getEvents(tokens : [Principal]) : async Event.Events {
        lp.getEvents(tokens);
    };

    public query func getEventsOfToken(token : Principal) : async [Event.Data] {
        lp.getEventsOfToken(token);
    };
};
