import HashMap "mo:base/HashMap";

import Ledger "Ledger";
import Interface "Interface";

module {
    // -----------------------------------------------------------------------//
    // 🟦 PUBLIC DATA STRUCTURES

    public type Interface = {
        // Creates a new event based on the given arguments. The given canister principal is expected to implement the
        // `Interface.DIP721Interface` so the initial available token can be set.
        createEvent : shared (args : Event) -> async ();
        // Returns all event.
        getEvents : query () -> async [Event];
        // Returns all available token of the event.
        getEventAvailable : query (name : EventName) -> async [Nat];
    };

    public type EventType = {
        #PublicSale
    };

    type EventName = Text;

    public type Event = {
        // Name of the event.
        name          : EventName;
        // Description of the event.
        description   : Text;
        // Start of the event.
        starts_at     : Int;
        // End of the event.
        ends_at       : Int;
        // Price of 1 token.
        price         : Ledger.Tokens;
        // The principal of the token canister.
        canister      : Text;
        // The type of the event.
        eventType     : EventType;
    };

    // -----------------------------------------------------------------------//
    // 🟨 INTERNAL DATA STRUCTURES
    
    // TODO: make an internal version of every event type that can be updated...
    // Maybe every event should be a object with a fixed interface? Yet, Motoko
    // does not really to type casting... so maybe just keep the enum?
    module Internal {
        type EventName = Text;

        type Events = HashMap.HashMap<EventName, EventClassInterface>;

        type EventClassInterface = {
            setName  : (t : EventName) -> ();
            // etc.
            syncAvailable : shared () -> async ();
        };

        shared func ownerTokenIds(canister : Text, owner : Principal) : async [Nat] {
            let c : Interface.DIP721Interface = actor(canister);
            switch (await c.ownerTokenIds(owner)) {
                case (#Ok(ids)) ids;
                case (_) { assert(false); loop {} };
            };
        };

        func CreateEvent(args : Event, _owner : Principal) : EventClassInterface {
            switch (args.eventType) {
                case (#PublicSale) object {
                    var name      = args.name;
                    var desc      = args.description;
                    var start     = args.starts_at;
                    var end       = args.ends_at;
                    var price     = args.price;
                    var canister  = args.canister;
                    var available = [] : [Nat];

                    public func setName(t : EventName) { name := t };

                    public shared func syncAvailable() : async () {
                        available := await ownerTokenIds(canister, _owner);
                    };
                };
                // etc.
            };
        };
    };
};
