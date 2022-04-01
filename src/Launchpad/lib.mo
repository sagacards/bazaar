import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";

import Event "Event";
import NFT "NFT";

module {
    public type Interface = actor {
        /// Creates a new event.
        createEvent : shared (data : Event.Data) -> async Nat;
        /// Updates an existing event.
        updateEvent : shared (index : Nat, data : Event.Data) -> async ();
        /// Returns all events of the {caller}.
        getOwnEvents : query () -> async [Event.Data];
        /// Returns all events.
        getAllEvents : query () -> async Event.Events;
        /// Returns all events for the given tokens.
        getEvents : query (tokens : [Principal]) -> async Event.Events;
        /// Returns the events for the given token.
        getEventsOfToken : query (token : Principal) -> async [Event.Data];
    };

    public class Launchpad() {
        let events = HashMap.HashMap<Principal, Buffer.Buffer<Event.Data>>(
            0, Principal.equal, Principal.hash,
        );

        public func createEvent(canister : Principal, data : Event.Data) : Nat {
            switch (events.get(canister)) {
                case (null) {
                    let b = Buffer.Buffer<Event.Data>(1);
                    b.add(data);
                    events.put(canister, b);
                    0;
                };
                case (? b) {
                    let s = b.size();
                    b.add(data);
                    s;
                };
            };
        };

        public func updateEvent(canister : Principal, index : Nat, data : Event.Data) {
            switch (events.get(canister)) {
                case (null) assert(false);
                case (? b) {
                    assert(index < b.size());
                    b.put(index, data);
                };
            };
        };

        public func getAllEvents() : Event.Events {
            Events.toStable(events);
        };

        public func getEvents(tokens : [Principal]) : Event.Events {
            Events.toStableFilter(events, tokens);
        };

        public func getEventsOfToken(token : Principal) : [Event.Data] {
            switch (events.get(token)) {
                case (null) [];
                case (? b)  b.toArray();
            };
        };
    };

    private type EventsMap = HashMap.HashMap<Principal, Buffer.Buffer<Event.Data>>;
    private type EventsTuple = (Principal, Buffer.Buffer<Event.Data>);

    private module Events = {
        public func toStable(events : EventsMap) : Event.Events {
            let buffer = Buffer.Buffer<(Principal, Event.Data)>(size(events));
            for ((p, b) in events.entries()) {
                for (d in b.vals()) buffer.add((p, d));
            };
            buffer.toArray();
        };

        public func toStableFilter(events : EventsMap, tokens : [Principal]) : Event.Events {
            let filter = func ((p, _) : EventsTuple) : Bool {
                for (t in tokens.vals()) if (t == p) return true;
                false;
            };

            let buffer = Buffer.Buffer<(Principal, Event.Data)>(sizeFilter(events, filter));
            for ((p, b) in entriesFilter(events, filter)) {
                for (d in b.vals()) buffer.add((p, d));
            };
            buffer.toArray();
        };

        private func size(events : EventsMap) : Nat {
            var size = 0;
            for ((_, b) in events.entries()) size += b.size();
            size;
        };

        private func sizeFilter(events : EventsMap, f : (e : EventsTuple) -> Bool) : Nat {
            var size = 0;
            for ((p, b) in events.entries()) if (f((p, b))) size += b.size();
            size;
        };

        private func entriesFilter(events : EventsMap, f : (e : EventsTuple) -> Bool) : Iter.Iter<EventsTuple> {
            Iter.filter(events.entries(), f);
        };
    };
};
