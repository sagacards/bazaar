import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import Launchpad "../../src/Launchpad";
import Event "../../src/Launchpad/Event";
import NFT "../../src/Launchpad/NFT";

shared({caller = owner}) actor class MockNFT(
    LAUNCHPAD_ID : Text
) : async NFT.Interface {
    private let lp : Launchpad.Interface = actor(LAUNCHPAD_ID);
    private var i : Nat = 0;
    private let total = 100;
    private let ledger = HashMap.HashMap<Principal, Nat>(
        0, Principal.equal, Principal.hash
    );

    public shared({caller}) func launchpadMint(p : Principal) : async Result.Result<Nat, NFT.MintError> {
        assert(caller == Principal.fromActor(lp));
        if (i >= total) return #err(#NoneAvailable);
        ledger.put(p, i);
        i += 1;
        #ok(i - 1);
    };

    public query({caller}) func launchpadTotalAvailable() : async Nat {
        assert(caller == Principal.fromActor(lp));
        total - i;
    };

    public shared({caller}) func launchpadEventCreate(data : Event.Data) : async Nat {
        assert(caller == owner);
        await lp.createEvent(data);
    };

    public shared({caller}) func launchpadEventUpdate(index : Nat, data : Event.Data) : async () {
        assert(caller == owner);
        await lp.updateEvent(index, data);
    };
};
