import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import List "mo:base/List";

import Ledger "../src/Ledger";
import Interface "../src/Interface";
import Events "../src/Events";
import NFT "../src/NFT";

shared({caller = owner}) actor class MockNFT(
    LAUNCHPAD_ID : Text
) : async NFT.Interface {

    private stable var admins : List.List<Principal> = ?(owner, null);

    private func isAdmin(caller : Principal) {
        assert(List.find(admins, func (p : Principal) : Bool { p == caller }) != null);
    };

    public shared({caller}) func addAdmin(a : Principal) {
        isAdmin(caller);
        admins := ?(a, admins);
    };

    public query func getAdmins() : async [Principal] {
        List.toArray(admins);
    };

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

    public shared({caller}) func launchpadEventCreate(data : Events.Data) : async Nat {
        isAdmin(caller);
        await lp.createEvent(data);
    };

    public shared({caller}) func launchpadEventUpdate(index : Nat, data : Events.Data) : async Events.Result<()> {
        isAdmin(caller);
        await lp.updateEvent(index, data);
    };

    public shared({caller}) func withdrawAll(to : Ledger.AccountIdentifier) : async Ledger.TransferResult {
        isAdmin(caller);
        let amount = await lp.balance();
        await lp.transfer(amount, to);
    };
};
