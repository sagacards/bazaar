import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

import Ledger "../../src/Ledger";
import Interface "../../src/Interface";
import Event "../../src/Events/Event";
import NFT "../../src/NFT";

shared({caller = owner}) actor class MockNFT(
    LAUNCHPAD_ID : Text
) : async NFT.Interface {
    private let lp : Interface.Main = actor(LAUNCHPAD_ID);
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

    public query({caller}) func launchpadTotalAvailable(event : Nat) : async Nat {
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

    public shared({caller}) func withdrawAll(to : Ledger.AccountIdentifier) : async Ledger.TransferResult {
        assert(caller == owner);
        let amount = await lp.balance();
        await lp.transfer(amount, to);
    };
};
