import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";

import Canistergeek "mo:canistergeek/canistergeek";

import AccountIdentifier "src/AccountIdentifier";
import Events "src/Events";
import Interface "src/Interface";
import Ledger "src/Ledger";
import NFT "src/NFT";

shared({caller}) actor class Rex(
    LEDGER_ID : Text,
) : async Interface.Main = this {
    private let ledger : Ledger.Interface = actor(LEDGER_ID);

    // To be able to test time-based events, we need to be able to manipulate time. This value should always be `null` 
    // in production, otherwise we will be stuck in time.
    private var testTime : ?Time.Time = null;

    private func now() : Time.Time = switch (testTime) {
        case (null) Time.now();
        case (? tt) tt;  
    };

    public func getTestTime() : async Time.Time { now() };

    public shared({caller}) func setTestTime(tt : ?Time.Time) {
        isAdmin(caller);
        testTime := tt;
    };

    /// List of admins.
    private stable var admins : List.List<Principal> = ?(caller, null);

    // 🏗 SYSTEM

    private stable var events : Events.Events = [];
    private let events_ = Events.Events.fromStable(events);
    events := [];

    private stable var _canistergeekMonitorUD: ? Canistergeek.UpgradeData = null;
    private stable var _canistergeekLoggerUD: ? Canistergeek.LoggerUpgradeData = null;

    system func preupgrade () {
        events := Events.Events.toStable(events_);
        _canistergeekMonitorUD := ? canistergeekMonitor.preupgrade();
        _canistergeekLoggerUD := ? canistergeekLogger.preupgrade();
    };

    system func postupgrade() {
        canistergeekMonitor.postupgrade(_canistergeekMonitorUD);
        _canistergeekMonitorUD := null;

        canistergeekLogger.postupgrade(_canistergeekLoggerUD);
        _canistergeekLoggerUD := null;
    };

    // 🛑 ADMIN

    /// 🛑 @modifier
    private func isAdmin(caller : Principal) {
        assert(List.find(admins, func (p : Principal) : Bool { p == caller }) != null);
    };

    /// 🛑
    public shared({caller}) func addAdmin(a : Principal) {
        isAdmin(caller);
        canistergeekMonitor.collectMetrics();
        admins := ?(a, admins);
    };

    /// 🛑
    public shared({caller}) func removeAdmin(a : Principal) {
        isAdmin(caller);
        canistergeekMonitor.collectMetrics();
        admins := List.filter(admins, func (p : Principal) : Bool { p != a });
    };

    /// 🛑
    public query({caller}) func getAdmins() : async [Principal] {
        isAdmin(caller);
        List.toArray(admins);
    };

    public shared({caller}) func removeEvent(token : Principal, index : Nat) {
        isAdmin(caller);
        canistergeekMonitor.collectMetrics();
        Events.Events.remove(events_, token, index);
    };

    // 👀 LOGGING & MONITORING

    private let canistergeekMonitor = Canistergeek.Monitor();
    private let canistergeekLogger = Canistergeek.Logger();

    private func _log (
        caller  : Principal,
        method  : Text,
        message : Text,
    ) : () {
        canistergeekLogger.logMessage(
            Principal.toText(caller) # " :: " #
            method # " :: " #
            message
        );
    };

    /// 🛑
    public query ({caller}) func getCanisterLog(request: ?Canistergeek.CanisterLogRequest) : async ?Canistergeek.CanisterLogResponse {
        isAdmin(caller);
        canistergeekLogger.getLog(request);
    };

    /// 🛑
    public query ({caller}) func getCanisterMetrics(parameters: Canistergeek.GetMetricsParameters): async ?Canistergeek.CanisterMetrics {
        isAdmin(caller);
        canistergeekMonitor.getMetrics(parameters);
    };

    /// 🛑
    public shared ({caller}) func collectCanisterMetrics(): async () {
        isAdmin(caller);
        canistergeekMonitor.collectMetrics();
    };
  
    // 🟢 PUBLIC

    public shared({caller}) func getAllowlistSpots(token : Principal, index : Nat) : async Result.Result<Int, Events.Error> {
        switch (Events.Events.getEventIndexData_(events_, token, index)) {
            case (#err(e))         #err(e);
            case (#ok({ access })) #ok(await Events.Access.getSpots(access, caller));
        };
    };

    public query({caller}) func getPersonalAccount() : async Ledger.AccountIdentifier {
        personalAccountOfPrincipal(caller);
    };

    private func personalAccountOfPrincipal(p : Principal) : Ledger.AccountIdentifier {
        AccountIdentifier.getAccount(Principal.fromActor(this), p);
    };

    public shared({caller}) func balance() : async Ledger.Tokens {
        canistergeekMonitor.collectMetrics();
        await ledger.account_balance({
            account = personalAccountOfPrincipal(caller);
        });
    };

    public shared({caller}) func transfer(amount : Ledger.Tokens, to : Ledger.AccountIdentifier) : async Ledger.TransferResult {
        canistergeekMonitor.collectMetrics();
        await ledger.transfer({
            memo            = 0;
            amount;
            fee             = { e8s = 10_000 };
            from_subaccount = ?Blob.fromArray(AccountIdentifier.principal2SubAccount(caller));
            to;
            created_at_time = null;
        });
    };

    private func totalAvailable(
        token : Principal, index : Nat,
        data : Events.Data_, revert : () -> ()
    ) : async Interface.MintResult {
        let t : NFT.Interface = actor(Principal.toText(token));
        let available = try (await t.launchpadTotalAvailable(index)) catch (e) {
            revert();
            return #err(#TryCatchTrap(Error.message(e)));
        };
        if (available == 0 or available < data.minting) {
            revert();
            return #err(#NoneAvailable);
        };
        #ok(available);
    };

    /// Returns a non null MintError if either the transfer failed, or if the ledger trapped.
    private func buy(
        { e8s = amount } : Ledger.Tokens, token : Principal, 
        caller : Principal,
        revert : () -> ()
    ) : async Result.Result<(), Interface.MintError> {
        if (amount <= 10_000) return #ok;

        try (switch (await ledger.transfer({
            memo            = 0;
            amount          = { e8s = amount - 10_000};
            fee             = { e8s = 10_000 };
            // From the account of the caller.
            from_subaccount = ?Blob.fromArray(AccountIdentifier.principal2SubAccount(caller));
            // To the account of the token.
            to              = AccountIdentifier.getAccount(Principal.fromActor(this), token);
            created_at_time = null;
        })) {
            case (#Ok(_)) #ok; // Ok, no error occurred.
            case (#Err(err)) {
                revert();
                #err(#Transfer(err)); // The transfer failed...
            };
        }) catch (e) {
            revert();
            #err(#TryCatchTrap(Error.message(e))); // The ledger trapped.
        };
    };

    private func mintToken(
        token : Principal, caller : Principal,
        data : Events.Data_, revert : () -> ()
    ) : async Interface.MintResult {
        let t : NFT.Interface = actor(Principal.toText(token));
        switch(try (await t.launchpadMint(caller)) catch (e) {
            #err(#TryCatchTrap(Error.message(e)));
        }) {
            case (#err(e)) {
                switch (e) {
                    case (#TryCatchTrap(m)) _log(caller, "mintToken", "ERR :: launchpadMint :: " # m);
                    case _ ();
                };
                revert();
                // TODO: for now I will just assume that that refund tx does not trap...
                //       maybe this can be solved by a queue + retrying? 
                switch (await ledger.transfer({
                    memo            = 0;
                    amount          = data.metadata.price;
                    fee             = { e8s = 10_000 };
                    // From the account of the token.
                    from_subaccount = ?Blob.fromArray(AccountIdentifier.principal2SubAccount(token));
                    // To the account of the caller.
                    to              = AccountIdentifier.getAccount(Principal.fromActor(this), caller);
                    created_at_time = null;
                })) {
                    case (#Ok(_))  #err(#Refunded);
                    case (#Err(e)) #err(#Transfer(e));
                };
            };
            case (#ok(n)) {
                data.minting -= 1;
                #ok(n);
            };
        };
    };

    /// Returns how many principals are currently waiting on the mint endpoint.
    public query func currentlyMinting(token : Principal, index : Nat) : async Result.Result<Nat, Events.Error> {
        switch (Events.Events.getEventIndexData_(events_, token, index)) {
            case (#err(e))   #err(e);
            case (#ok(data)) #ok(data.minting);
        };
    };

    public shared({caller}) func mint(token : Principal, index : Nat) : async Interface.MintResult {
        canistergeekMonitor.collectMetrics();
        let data = switch (Events.Events.getEventIndexData_(events_, token, index)) {
            case (#err(e))   return #err(#Events(e));
            case (#ok(data)) data;
        };
        switch (Events.inEventPeriod(data.metadata, now())) {
            case (#err(e)) return #err(#Events(e));
            case (#ok) {};
        };
        switch (await Events.Access.removeSpot(data.access, caller)) {
            case (#err(e)) return #err(#Events(e));
            case (#ok) {};
        };

        data.minting += 1;
        let revert = func () {
            Events.Access.addSpot(data.access, caller);
            data.minting -= 1;
        };

        let available = switch (await totalAvailable(token, index, data, revert)) {
            case (#ok(a))  a;
            case (#err(e)) return #err(e);
        };
        switch (await buy(data.metadata.price, token, caller, revert)) {
            case (#ok)  {};
            case (#err(e)) return #err(e);
        };
        await mintToken(token, caller, data, revert);
    };

    // 🚀 LAUNCHPAD

    private let createEventPrice = 0; // 1T;
    private let updateEventPrice = 0;

    private func chargeCycles(amount : Nat) : Bool {
        if (Cycles.available() < amount)    return false;
        if (Cycles.accept(amount) < amount) return false;
        true;
    };

    public shared({caller}) func createEvent(data : Events.Data) : async Nat {
        assert(chargeCycles(createEventPrice));
        canistergeekMonitor.collectMetrics();
        Events.Events.add(events_, caller, data);
    };

    public shared({caller}) func updateEvent(index : Nat, data : Events.Data) : async Events.Result<()> {
        assert(chargeCycles(updateEventPrice));
        canistergeekMonitor.collectMetrics();
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
