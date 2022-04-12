import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import AccountIdentifier "AccountIdentifier";
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

    private stable var events : Events.Events = [];
    private let events_ = Events.Events.fromStable(events);
    events := [];

    system func preupgrade () {
        events := Events.Events.toStable(events_);
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

    public query({caller}) func getAllowlistSpots(token : Principal, index : Nat) : async Result.Result<Int, Events.Error> {
        Events.Events.getSpots(events_, token, index, caller);
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

    /// Returns a non null MintError if either the transfer failed, or if the ledger trapped.
    private func buy(amount : Ledger.Tokens, token : Principal, caller : Principal) : async ?Interface.MintError {
        try (switch (await ledger.transfer({
            memo            = 0;
            amount          = amount;
            fee             = { e8s = 10_000 };
            // From the account of the caller.
            from_subaccount = ?Blob.fromArray(AccountIdentifier.principal2SubAccount(caller));
            // To the account of the token.
            to              = AccountIdentifier.getAccount(Principal.fromActor(this), token);
            created_at_time = null;
        })) {
            // Ok, no error occurred.
            case (#Ok(_))    null;
            // The transfer failed...
            case (#Err(err)) ?#Transfer(err);
        }) catch (_) {
            // The ledger trapped.
            ?#TryCatchTrap;
        };
    };

    /// The amount of principals that are currently minting...
    /// It is basically a simple mutex lock?...
    private var minting = 0;

    /// Returns how many principals are currently waiting on the mint endpoint.
    public query func currentlyMinting() : async Nat { minting };

    public shared({caller}) func mint(token : Principal, index : Nat) : async Interface.MintResult {
        switch (Events.Events.getSpots(events_, token, index, caller)) {
            case (#err(e)) return #err(#Events(e));
            case (#ok(v))  if (v == 0) return #err(#NoMintingSpot);
        };
        let price = switch(Events.Events.getPrice(events_, token, index)) {
            case (#err(e)) return #err(#Events(e));
            case (#ok(price)) price;
        };
        let t : NFT.Interface = actor(Principal.toText(token));
        let available = await t.launchpadTotalAvailable(index);
        if (available <= minting) return #err(#NoneAvailable);

        // TODO: Check that we subtract 1 on every occurrence that the function exits.
        // TODO: Add endpoint to reset this?
        minting += 1;

        switch (await buy(price, token, caller)) {
            case (null)  {};
            // NOTE: Failure here: type mismatch: type on the wire rec_1, expect type nat
            case (? e) {
                minting -= 1;
                return #err(e);
            };
        };
 
        // TODO: add one again if something goes wrong?
        switch (Events.Events.removeSpot(events_, token, index, caller)) {
            case (#err(e)) return #err(#Events(e));
            case (#ok(_))  {};
        };
        let r = try (await t.launchpadMint(caller)) catch (_) {
            #err(#TryCatchTrap);
        };
        // Mint either succeeded or failed, so available should be updated.
        minting -= 1;

        switch (r) {
            case (#err(_)) {
                // TODO: refund + add spot again.
                assert(false);
                loop {};
            };
            case (#ok(n)) #ok(n);
        };
    };

    // 🚀 LAUNCHPAD

    private let createEventPrice = 0; // 1T;
    private let updateEventPrice = 0;

    private func chargeCycles(amount : Nat) : Bool {
        if (Cycles.available() < amount)        return false;
        if (Cycles.accept(amount) < amount) return false;
        true;
    };

    public shared({caller}) func createEvent(data : Events.Data) : async Nat {
        assert(chargeCycles(createEventPrice));
        Events.Events.add(events_, caller, data);
    };

    public shared({caller}) func updateEvent(index : Nat, data : Events.Data) : async Events.Result<()> {
        assert(chargeCycles(updateEventPrice));
        Events.Events.replace(events_, caller, index, data);
    };

    public query func getEvent(token : Principal, index : Nat) : async Events.Result<Events.Data> {
        Events.Events.getEventIndexData(events_, token, index);
    };

    public query({caller}) func getOwnEvents() : async [Events.Data] {
        switch (Events.Events.getEventData(events_, caller)) {
            case (#err(_))   [];
            case (#ok(data)) data;
        };
    };

    public query func getAllEvents() : async Events.Events {
        Events.Events.toStable(events_);
    };

    public query func getEvents(tokens : [Principal]) : async Events.Events {
        Events.Events.toStableFilter(events_, tokens);
    };

    public query func getEventsOfToken(token : Principal) : async [Events.Data] {
        switch (Events.Events.getEventData(events_, token)) {
            case (#err(_))   [];
            case (#ok(data)) data;
        };
    };
};
