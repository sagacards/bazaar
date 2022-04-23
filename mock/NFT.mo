import Buffer "mo:base/Buffer";
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

    private func isAdmin(caller : Principal) = assert(_isAdmin(caller));

    private func _isAdmin(caller : Principal) : Bool {
        List.find(admins, func (p : Principal) : Bool { p == caller }) != null;
    };

    public shared({caller}) func addAdmin(a : Principal) {
        isAdmin(caller);
        admins := ?(a, admins);
    };

    public query func getAdmins() : async [Principal] {
        List.toArray(admins);
    };

    public shared({caller}) func transfer(to : Ledger.AccountIdentifier) : async Ledger.TransferResult {
        isAdmin(caller);
        let amount = await lp.balance();
        await lp.transfer(amount, to);
    };

    public shared({caller}) func getPersonalAccount() : async Ledger.AccountIdentifier {
        await lp.getPersonalAccount();
    };

    public shared({caller}) func reset(_total : Nat) {
        isAdmin(caller);
        i      := 0;
        total  := _total;
        ledger := HashMap.HashMap<Principal, Buffer.Buffer<Nat>>(
            total, Principal.equal, Principal.hash
        );
    };

    public query({caller}) func launchpadTotalSupply(event : Nat) : async Nat {
        total;
    };

    public shared({caller}) func launchpadEventCreate(data : Events.Data) : async Nat {
        isAdmin(caller);
        await lp.createEvent(data);
    };

    public shared({caller}) func launchpadEventUpdate(index : Nat, data : Events.Data) : async Events.Result<()> {
        isAdmin(caller);
        await lp.updateEvent(index, data);
    };

    private var trap = false;

    public shared({caller}) func toggleTrap(_trap : Bool) {
        isAdmin(caller);
        trap := _trap;
    };

    private let lp : Interface.Main = actor(LAUNCHPAD_ID);

    private var i : Nat = 0;
    private var total = 100;
    private var ledger = HashMap.HashMap<Principal, Buffer.Buffer<Nat>>(
        total, Principal.equal, Principal.hash
    );

    public shared({caller}) func launchpadMint(p : Principal) : async Result.Result<Nat, NFT.MintError> {
        assert(caller == Principal.fromActor(lp) or _isAdmin(caller));
        if (trap) assert(false);

        if (total <= i) return #err(#NoneAvailable);
        let buffer = switch (ledger.get(p)) {
            case (null) {
                let b = Buffer.Buffer<Nat>(1);
                ledger.put(p, b);
                b;
            };
            case (? buffer) buffer;
        };
        buffer.add(i);
        i += 1;
        #ok(i - 1);
    };

    public query({caller}) func launchpadTotalAvailable(event : Nat) : async Nat {
        total - i;
    };

    public query func launchpadBalanceOf(user : Principal) : async Nat {
        switch (ledger.get(user)) {
            case (null)     0;
            case (? buffer) buffer.size();
        };
    };

    public query({caller}) func balance() : async [Nat] {
        switch (ledger.get(caller)) {
            case (null) [];
            case (? buffer) buffer.toArray();
        };
    };
};
