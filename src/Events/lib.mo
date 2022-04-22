import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Time "mo:base/Time";

import Ledger "../Ledger";

module {
    public type Error = {
        /// The caller is not in the allowlist.
        #NotInAllowlist;
        /// Indicates that the given token was not found.
        #TokenNotFound : (token : Principal);
        /// Indicates that the given index was not found for the event.
        #IndexNotFound : (index : Nat);
        /// Indicates that the event did not start yet.
        #NotStarted : (dt : Time.Time);
        /// Indicates that the event is already over.
        #AlreadyOver : (dt : Time.Time);
    };

    public type Result<T> = Result.Result<T, Error>;

    // These are just type to make the code more readable...
    private type EventName = Text;
    private type Spots     = ?Int;
    private type URL       = Text;

    // The public representation of an allowlist.
    // e.g. [(a, ?-1),  (b, ?5), (c, ?2), (d, ?1), (e, null)];
    // - `a` has unlimited access.
    // - `b` and `c` have `5` and `2` spots respectively.
    // - `d` has 1 spot.
    // - `e` will be ignored.
    public type Allowlist = [(user : Principal, spots : Spots)];

    // The internal representation of a StableAllowlist;
    public type Allowlist_ = HashMap.HashMap<Principal, Spots>;

    public module Allowlist = {
        public func toStable(list_ : Allowlist_) : Allowlist = Iter.toArray(
            list_.entries()
        );

        public func fromStable(list : Allowlist) : Allowlist_ = HashMap.fromIter(
            list.vals(), list.size(), Principal.equal, Principal.hash
        );

        public func removeSpot(list_ : Allowlist_, user : Principal) : Result<Int> {
            ignore do ? {
                let spots = list_.get(user)!!;
                if (spots < 0)  return #ok(-1);
                if (spots == 0) return #err(#NotInAllowlist);
                let new = spots - 1;
                switch (new) {
                    case (0)     list_.delete(user);
                    case (spots) list_.put(user, ?spots);
                };
                return #ok(new);
            };
            #err(#NotInAllowlist);
        };

        public func addSpot(list_ : Allowlist_, user : Principal) {
            switch (do ? {
                let spots = list_.get(user)!!;
                if (spots < 0) return;
                list_.put(user, ?(spots + 1));
            }) {
                case (null) list_.put(user, ?1);
                case (_) {};
            };
        };
    };

    /// Describes the access of the event.
    public type Access = {
        // Denotes a public event without restrictions.
        #Public;
        // Denotes an event with limited access.
        #Private : Allowlist;
    };

    public type Access_ = {
        #Public;
        #Private : Allowlist_;
    };

    public module Access = {
        public func toStable(access_ : Access_) : Access = switch (access_) {
            case (#Public)        #Public;
            case (#Private(list)) #Private(Allowlist.toStable(list));
        };

        public func fromStable(access : Access) : Access_ = switch (access) {
            case (#Public)        #Public;
            case (#Private(list)) #Private(Allowlist.fromStable(list));
        };

        public func getSpots(access_ : Access_, user : Principal) : Int = switch (access_) {
            case (#Public)        -1;
            case (#Private(list)) switch (list.get(user)) {
                case (null)    0;
                case (? spots) switch (spots) {
                    case (null)    0;
                    case (? spots) spots;
                };
            };
        };

        public func removeSpot(access_ : Access_, user : Principal) : Result<Int> = switch (access_) {
            case (#Public)        #ok(-1);
            case (#Private(list)) Allowlist.removeSpot(list, user);
        };

        public func addSpot(access_ : Access_, user : Principal) = switch (access_) {
            case (#Public) {};
            case (#Private(list)) Allowlist.addSpot(list, user);
        };
    };

    public type Event  = (token : Principal, data : Data, index : Nat);
    public type Events  = [Event];
    public type Events_ = HashMap.HashMap<Principal, Buffer.Buffer<Data_>>;

    public module Events = {
        public func add(events_ : Events_, token : Principal, data : Data) : (index : Nat) {
            let data_ = Data.fromStable(data);
            let buffer = switch (events_.get(token)) {
                case (null) {
                    let buffer = Buffer.Buffer<Data_>(1);
                    events_.put(token, buffer);
                    buffer;
                };
                case (? buffer) buffer;
            };
            let index = buffer.size();
            buffer.add(data_);
            index;
        };

        public func replace(events_ : Events_, token : Principal, index : Nat, data: Data) : Result<()> {
            let data_ = Data.fromStable(data);
            switch (events_.get(token)) {
                case (null) return #err(#TokenNotFound(token));
                case (? buffer) {
                    if (buffer.size() <= index) return #err(#IndexNotFound(index));
                    buffer.put(index, data_);
                    #ok;
                };
            };
        };

        public func remove(events_ : Events_, token : Principal, index : Nat) {
            switch (events_.get(token)) {
                case (null) {};
                case (? buffer) {
                    var new = Buffer.Buffer<Data_>(buffer.size());
                    var i = 0;
                    for (data in buffer.vals()) {
                        if (i != index) new.add(data);
                        i += 1;
                    };
                    events_.put(token, new);
                };
            };
        };

        public func fromStable(events : Events) : Events_ {
            let events_ : Events_ = HashMap.HashMap(
                events.size(), Principal.equal, Principal.hash
            );
            for ((p, data, _) in events.vals()) {
                let b = switch (events_.get(p)) {
                    case (null) {
                        // NOTE: we assume that in general a token only has one event...
                        let b = Buffer.Buffer<Data_>(1);
                        events_.put(p, b);
                        b;
                    };
                    case (? b) b;
                };
                let data_ = Data.fromStable(data);
                b.add(data_);
            };
            events_;
        };

        public func toStable(events_ : Events_) : Events {
            // NOTE: we assume that at least one token has more than one, so we already rescale.
            let events = Buffer.Buffer<Event>(events_.size() * 2);
            for ((token, buffer) in events_.entries()) {
                var index = 0;
                for (data in buffer.vals()) {
                    events.add(token, Data.toStable(data), index);
                    index += 1;
                };
            };
            events.toArray();
        };

        public func toStableFilter(events_ : Events_, tokens : [Principal]) : Events {
            let events = Buffer.Buffer<Event>(events_.size());
            label l for ((token, buffer) in events_.entries()) {
                var hit = false;
                label t for (tk in tokens.vals()) if (tk == token) {
                    hit := true;
                    break t;
                };
                if (not hit) continue l;

                var index = 0;
                for (data in buffer.vals()) {
                    events.add(token, Data.toStable(data), index);
                    index += 1;
                };
            };
            events.toArray();
        };

        public func getEventData(events_ : Events_, token : Principal) : Result<[Data]> = switch (events_.get(token)) {
            case (null)     #err(#TokenNotFound(token));
            case (? buffer) {
                let data = Buffer.Buffer<Data>(buffer.size());
                for (data_ in buffer.vals()) data.add(Data.toStable(data_));
                #ok(data.toArray());
            };
        };

        public func getEventIndexData(events_ : Events_, token : Principal, index : Nat) : Result<Data> = switch (events_.get(token)) {
            case (null)     #err(#TokenNotFound(token));
            case (? buffer) switch(buffer.getOpt(index)) {
                case (null)    #err(#IndexNotFound(index));
                case (? data_) #ok(Data.toStable(data_));
            };
        };

        public func getEventIndexData_(events_ : Events_, token : Principal, index : Nat) : Result<Data_> = switch (events_.get(token)) {
            case (null)     #err(#TokenNotFound(token));
            case (? buffer) switch(buffer.getOpt(index)) {
                case (null)    #err(#IndexNotFound(index));
                case (? data_) #ok(data_);
            };
        };
    };

    public type MetaData = {
        // Name of the event.
        name        : EventName;
        // Description of the event.
        description : Text;
        // Start of the event.
        startsAt    : Time.Time;
        // End of the event.
        endsAt      : Time.Time;
        // Price of 1 token.
        price       : Ledger.Tokens;
        // The details of the collection.
        details     : CollectionDetails;
    };

    public func inEventPeriod({ startsAt; endsAt } : MetaData, now : Time.Time) : Result.Result<(), Error> {
        if (now < startsAt) return #err(#NotStarted(startsAt - now));
        if (endsAt <= now)  return #err(#AlreadyOver(now - endsAt));
        #ok;
    };

    public type Data = MetaData and {
        // The access (type) of the event. Can be either:
        // - #Public  : accessible for everyone.
        // - #Private : only accessible by principals in the allowlist.
        accessType  : Access;
    };

    public type Data_ = {
        metadata    : MetaData;
        var minting : Nat;
        access      : Access_;
    };

    public module Data = {
        public func metadata(data : Data) : MetaData = data;

        public func toStable({ metadata; access } : Data_) : Data = {
            accessType  = Access.toStable(access);
            description = metadata.description;
            details     = metadata.details;
            endsAt      = metadata.endsAt;
            name        = metadata.name;
            price       = metadata.price;
            startsAt    = metadata.startsAt;
        };

        public func fromStable(data : Data) : Data_ = {
            metadata    = metadata(data);
            var minting = 0;
            access      = Access.fromStable(data.accessType);
        };
    };

    public type CollectionDetails = {
        iconImageUrl           : URL;
        bannerImageUrl         : URL;
        previewImageUrl        : URL;
        descriptionMarkdownUrl : URL;
    };
};
