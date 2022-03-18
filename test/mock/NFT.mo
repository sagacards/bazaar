import DIP721 "mo:dip/DIP721";
import Interface "../../src/Interface";

shared({caller = owner}) actor class MockNFT() : async Interface.DIP721Interface {
    public query func ownerTokenIds(owner : Principal) : async DIP721.Result<[Nat]> {
        #Ok([1, 2, 3]);
    };
};
