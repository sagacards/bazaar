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
        /// Indicates that you are not in the allowlist and are not allowed to mint.
        #NoMintingSpot;
        /// Indicates that no more NFTs are available.
        #NoneAvailable;
        /// Indicates that an external services trapped...
        #TryCatchTrap : Text;
    };

    /// 🟢 Public functions.
    public type Account = actor {
        getAllowlistSpots : query (token : Principal, index : Nat) -> async Result.Result<Int, Events.Error>;
        getPersonalAccount : query () -> async Ledger.AccountIdentifier;
        balance : shared () -> async Ledger.Tokens;
        transfer : shared (amount : Ledger.Tokens, to : Ledger.AccountIdentifier) -> async Ledger.TransferResult;
        mint : shared (token : Principal, index : Nat) -> async MintResult;
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
