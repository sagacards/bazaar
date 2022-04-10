import Events "lib";

module {
    public type Interface = actor {
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
};
