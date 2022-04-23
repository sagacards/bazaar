import Result "mo:base/Result";

import AccountIdentifier "AccountIdentifier";
import Ledger "Ledger";
import Events "Events";

module Interface {
    /// 🛑 Admin restricted functions.
    public type Admin = actor {
        addAdmin : shared (a : Principal) -> ();
        removeAdmin : shared (a : Principal) -> ();
        getAdmins : query () -> async [Principal];
        removeEvent: shared (token : Principal, index : Nat) -> ();
    };

    public type MintResult = Result.Result<Nat, MintError>;

    public type MintError = {
        /// Describes a ledger transfer error.
        #Transfer : Ledger.TransferError;
        /// Indicates that the mint failed but the paid amount got refunded.
        #Refunded;
        /// Describes an event error;
        #Events : Events.Error;
        /// Indicates that no more NFTs are available.
        #NoneAvailable;
        /// Indicates that an external services trapped...
        #TryCatchTrap : Text;
    };

    /// 🟢 Public functions.
    public type Account = actor {
        // Returns the amount of spots the caller has for the given event.
        getAllowlistSpots : shared (token : Principal, index : Nat) -> async Result.Result<Int, Events.Error>;
        // Returns the personal canister account of the caller.
        getPersonalAccount : query () -> async Ledger.AccountIdentifier;
        // Returns the balance of the canister account.
        balance : shared () -> async Ledger.Tokens;
        // Transfers the specified amount from the canister account to the given `to` account.
        transfer : shared (amount : Ledger.Tokens, to : Ledger.AccountIdentifier) -> async Ledger.TransferResult;
        // Mint endpoint for the given token.
        // @pre: sufficient funds/supply, specified by the event.
        mint : shared (token : Principal, index : Nat) -> async MintResult;
        // The total amount of people that are currently minting for a given event.
        currentlyMinting : query (token : Principal, index : Nat) -> async Result.Result<Nat, Events.Error>;
    };

    public type Events = actor {
        /// Creates a new event.
        createEvent : shared (data : Events.Data) -> async Nat;
        /// Updates an existing event.
        updateEvent : shared (index : Nat, data : Events.Data) -> async Events.Result<()>;
        /// Returns a specific event for the given token.
        getEvent : query (token : Principal, index : Nat) -> async Events.Result<Events.Data>;
        /// Returns all events of the {caller}.
        getOwnEvents : query () -> async [Events.Data];
        /// Returns all events.
        getAllEvents : query () -> async Events.Events;
        /// Returns all events for the given tokens.
        getEvents : query (tokens : [Principal]) -> async Events.Events;
        /// Returns the events for the given token.
        getEventsOfToken : query (token : Principal) -> async [Events.Data];
    };

    public type Main = Admin and Account and Events;
};
