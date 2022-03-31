import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";

import Ledger "../Ledger";

module {
    // These are just type to make the code more readable...
    private type Time      = Int;
    private type EventName = Text;

    // The public representation of an allowlist.
    // e.g. [(a, -1),  (b, 5), (c, 2), (d, 1), (e, null)];
    // - `a` has unlimited access.
    // - `b` and `c` have `5` and `2` spots respectively.
    // - `d` has 1 spot.
    // - `e` will be ignored.
    public type StableAllowlist = [(Principal, ?Nat)];

    // The internal representation of a StableAllowlist;
    public type Allowlist = HashMap.HashMap<Principal, ?Nat>;

    public module Allowlist = {
        public func toStable(l : Allowlist) : StableAllowlist = Iter.toArray(
            l.entries()
        );

        public func fromStable(l : StableAllowlist) : Allowlist = HashMap.fromIter(
            l.vals(), l.size(), Principal.equal, Principal.hash
        );
    };

    /// Describes the access of the event.
    public type Access = {
        // Denotes a public event with a certain number of mints (-1 = unlimited).
        #Public : Int;
        // Denotes an event with limited access.
        #Private : StableAllowlist;
    };

    public type Data = {
        // Name of the event.
        name        : EventName;
        // Description of the event.
        description : Text;
        // Start of the event.
        startsAt    : Time;
        // End of the event.
        endsAt      : Time;
        // Price of 1 token.
        price       : Ledger.Tokens;
        // The details of the collection.
        details     : CollectionDetails;
        // The access (type) of the event. Can be either:
        // - #Public  : accessible for everyone.
        // - #Private : only accessible by principals in the allowlist.
        accessType  : Access;
    };

    /// Event describes a launchpad event.
    public type Event = Data and {
        // The principal of the token canister.
        //
        // FAQ: Why 'Text' instead of 'Principal'?
        //   A: `let c : = actor(canister);` expects `Text` instead of `Principal`.
        canister : Text;
    };

    public type CollectionDetails = {
        iconImageUrl           : Text;
        bannerImageUrl         : Text;

        // TODO: are these not too specific (ref. Saga)?
        cardImageUrl           : Text;
        descriptionMarkdownUrl : Text;
    };
};
