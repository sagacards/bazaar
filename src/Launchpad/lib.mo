import Event "Event";
import NFT "NFT";

module {
    public type Interface = {
        /// Returns all events.
        getAllEvents : query () -> async [Event.Event];
        /// Returns all events for the given tokens.
        getEvents : query (tokens : [Principal]) -> async [Event.Event];
        /// Returns the events for the given token.
        getEventsOfToken : query (token : Principal) -> async [Event.Event];
    };

    public class Launchpad() : Interface {
        public query func getAllEvents() : async [Event.Event] { [] };
        public query func getEvents(tokens : [Principal]) : async [Event.Event] { [] };
        public query func getEventsOfToken(token : Principal) : async [Event.Event] { [] };
    };
};
