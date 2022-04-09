import Result "mo:base/Result";
import AccountIdentifier "AccountIdentifier";
import Ledger "Ledger";

import Events "Events";

module Interface {
    /// 🛑 Admin restricted functions.
    public type Admin = actor {
        addAdmin : shared (a : Principal) -> ();
        removeAdmin : shared (a : Principal) -> ();
        getAdmins : query () -> async [Principal];
    };

    /// 🟢 Public functions.
    public type Account = actor {
        getAllowlistSpots : query (token : Principal, index : Nat) -> async ?Int;
        getPersonalAccount : query () -> async Ledger.AccountIdentifier;
        balance : shared () -> async Ledger.Tokens;
        transfer : shared (amount : Ledger.Tokens, to : Ledger.AccountIdentifier) -> async Ledger.TransferResult;
        mint : shared (token : Principal, index : Nat) -> async Result.Result<Nat, Ledger.TransferError>;
    };

    public type Main = Admin and Account and Events.Interface;
};
