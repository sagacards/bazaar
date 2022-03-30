import Event "Event";
import NFT "NFT";

module {
    public type Interface = actor {
        /// Returns all events of the {caller}.
        getOwnEvents : query () -> async [Event.Event];
        /// Returns all events.
        getAllEvents : query () -> async [Event.Event];
        /// Returns all events for the given tokens.
        getEvents : query (tokens : [Principal]) -> async [Event.Event];
        /// Returns the events for the given token.
        getEventsOfToken : query (token : Principal) -> async [Event.Event];
    };

    public type ClassInterface = {
        /// Returns all events.
        getAllEvents : () -> [Event.Event];
        /// Returns all events for the given tokens.
        getEvents : (tokens : [Principal]) -> [Event.Event];
        /// Returns the events for the given token.
        getEventsOfToken : (token : Principal) -> [Event.Event];
    };

    public class Launchpad() : ClassInterface {
        public func getAllEvents() : [Event.Event] { [] };
        public func getEvents(tokens : [Principal]) : [Event.Event] { [] };
        public func getEventsOfToken(token : Principal) : [Event.Event] { [] };
    };
};
