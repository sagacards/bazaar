import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import AccountIdentifier "AccountIdentifier";
import Event "Events/Event";
import Events "Events";
import Interface "Interface";
import Ledger "Ledger";
import NFT "NFT";

shared({caller}) actor class Rex(
    LEDGER_ID : Text,
) : async Interface.Main = this {
    private let ledger : Ledger.Interface = actor(LEDGER_ID);

    /// List of admins.
    private stable var admins : List.List<Principal> = ?(caller, null);

    // 🏗 SYSTEM

    private let emptyState = {
        var events : Events.StableState = {
            events = [];
        };
    };

    stable var state = emptyState;

    system func preupgrade () {
        state.events := events.toStable();
    };

    system func postupgrade() {
        state := emptyState;
    };

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

    // 🟢 PUBLIC

    public query({caller}) func getAllowlistSpots(canister : Principal, index : Nat) : async ?Int {
        let (n, _) = spots(caller, canister, index);
        n;
    };

    private func spots(caller : Principal, canister : Principal, index : Nat) : (n : ?Int, price : Ledger.Tokens) {
        switch (events.getEvent(canister, index)) {
            case (null) {
                assert(false); // invalid event.
                loop {};
            };
            case (? { accessType; price }) {
                switch (accessType) {
                    case (#Public) return (?-1, price);
                    case (#Private(list)) {
                        for ((p, v) in list.vals()) {
                            if (p == caller) return (v, price);
                        };
                        (null, price);
                    };
                };
            };
        };
    };

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

    private func buy(amount : Ledger.Tokens, token : Principal, caller : Principal) : async Ledger.TransferResult {
        await ledger.transfer({
            memo            = 0;
            amount;
            fee             = { e8s = 10_000 };
            from_subaccount = ?Blob.fromArray(AccountIdentifier.principal2SubAccount(caller));
            to              = AccountIdentifier.getAccount(Principal.fromActor(this), token);
            created_at_time = null;
        });
    };

    public shared({caller}) func mint(token : Principal, index : Nat) : async Result.Result<Nat, Ledger.TransferError> {
        let price = switch (spots(caller, token, index)) {
            case (null, _) {
                assert(false);
                loop {};
            };
            case (? v, price) {
                if (v == 0) assert(false);
                price;
            };
        };
        let t : NFT.Interface = actor(Principal.toText(token));
        // NOTE: a million people could end up buying the same token...
        let available = await t.launchpadTotalAvailable(index);
        // NOTE: Assertions give useless errors. Result please!
        assert(0 < available);
        switch (await buy(price, token, caller)) {
            case (#Ok(_))  {};
            // NOTE: Failure here: type mismatch: type on the wire rec_1, expect type nat
            case (#Err(e)) return #err(e);
        };
        // NOTE: from this point onwards, the user has paid!
        let r = try (await t.launchpadMint(caller)) catch (_) {
            #err(#TryCatchTrap);
        };
        switch (r) {
            case (#err(_)) {
                // TODO: refund!
                assert(false); #ok(0);
            };
            case (#ok(n)) {
                // TODO: lower allowlist entry!
                #ok(n);
            };
        };
    };

    // 🚀 LAUNCHPAD

    private let events = Events.Class(state.events);

    private let createEventPrice = 0; // 1T;
    private let updateEventPrice = 0;

    private func chargeCycles(amount : Nat) : Bool {
        if (Cycles.available() < amount)        return false;
        if (Cycles.accept(amount) < amount) return false;
        true;
    };

    public shared({caller}) func createEvent(data : Event.Data) : async Nat {
        assert(chargeCycles(createEventPrice));
        events.createEvent(caller, data);
    };

    public shared({caller}) func updateEvent(index : Nat, data : Event.Data) : async () {
        assert(chargeCycles(updateEventPrice));
        events.updateEvent(caller, index, data);
    };

    public query func getEvent(token : Principal, index : Nat) : async ?Event.Data {
        events.getEvent(token, index);
    };

    public query({caller}) func getOwnEvents() : async [Event.Data] {
        events.getEventsOfToken(caller);
    };

    public query func getAllEvents() : async Event.Events {
        events.getAllEvents();
    };

    public query func getEvents(tokens : [Principal]) : async Event.Events {
        events.getEvents(tokens);
    };

    public query func getEventsOfToken(token : Principal) : async [Event.Data] {
        events.getEventsOfToken(token);
    };
};
