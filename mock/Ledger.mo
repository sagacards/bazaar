import AId "mo:principal/blob/AccountIdentifier";
import Blob "mo:base/Blob";
import HashMap "mo:base/HashMap";
import List "mo:base/List";

import Ledger "../src/Ledger";

shared({caller = owner}) actor class MockLedger() : async Ledger.Interface {

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

    private var blockIndex : Ledger.BlockIndex = 0;
    private var balances = HashMap.HashMap<AId.AccountIdentifier, Nat64>(0, Blob.equal, Blob.hash);

    // Custom Endpoint!
    public shared({caller}) func reset() {
        isAdmin(caller);
        blockIndex := 0;
        balances   := HashMap.HashMap<AId.AccountIdentifier, Nat64>(0, Blob.equal, Blob.hash);
    };

    // Custom Endpoint!
    public shared({caller}) func mint(args : { to : Ledger.AccountIdentifier; amount : Ledger.Tokens }) : async Ledger.BlockIndex {
        isAdmin(caller);
        switch (balances.get(args.to)) {
            case (null)      balances.put(args.to, args.amount.e8s);
            case (? balance) balances.put(args.to, balance + args.amount.e8s);
        };
        let bI = blockIndex;
        blockIndex += 1;
        bI;
    };

    public shared({caller}) func mintAll(args : [{ to : Ledger.AccountIdentifier; amount : Ledger.Tokens }]) : async Ledger.BlockIndex {
        isAdmin(caller);
        for (args in args.vals()) {
            switch (balances.get(args.to)) {
                case (null)      balances.put(args.to, args.amount.e8s);
                case (? balance) balances.put(args.to, balance + args.amount.e8s);
            };
        };
        let bI = blockIndex;
        blockIndex += 1;
        bI;
    };

    // Custom Endpoint!
    public query func zeroAccount(p : Principal) : async AId.AccountIdentifier {
        AId.fromPrincipal(p, null);
    };

    public query func account_balance({ account } : Ledger.AccountBalanceArgs) : async Ledger.Tokens {
        switch (balances.get(account)) {
            case (? e8s) return { e8s };
            case (null)  return { e8s = 0 };
        };
    };

    public shared({caller}) func transfer(args : Ledger.TransferArgs) : async Ledger.TransferResult {
        if (args.fee.e8s != 10_000) return #Err(#BadFee({ expected_fee = { e8s = 10_000 } }));
        let subAccount : ?[Nat8] = switch(args.from_subaccount) {
            case (null)   null;
            case (? blob) ?Blob.toArray(blob);
        };
        let account = AId.fromPrincipal(caller, subAccount);
        switch (balances.get(account)) {
            case (null) return #Err(#InsufficientFunds({ balance = { e8s = 0} }));
            case (? balance) {
                let total = args.amount.e8s + args.fee.e8s;
                if (balance < total) return #Err(#InsufficientFunds({ balance = { e8s = balance } }));
                balances.put(account, balance - total);
                switch (balances.get(args.to)) {
                    case (null)      balances.put(args.to, args.amount.e8s);
                    case (? balance) balances.put(args.to, balance + args.amount.e8s);
                };
                let bI = blockIndex;
                blockIndex += 1;
                #Ok(bI);
            };
        };
    };
};
