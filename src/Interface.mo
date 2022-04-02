import AccountIdentifier "AccountIdentifier";
import Ledger "Ledger";

import Launchpad "Launchpad";

module Interface {
    /// 🛑 Admin restricted functions.
    public type Admin = actor {
        addAdmin : shared (a : Principal) -> ();
        removeAdmin : shared (a : Principal) -> ();
        getAdmins : query () -> async [Principal];
        setPrice : shared (e8s : Ledger.Tokens) -> ();
    };

    /// 🟢 Public functions.
    public type Account = actor {
        getAllowlistSpots : query (token : Principal, index : Nat) -> async ?Int;
        getPrice : query () -> async Ledger.Tokens;
        getPersonalAccount : query () -> async Ledger.AccountIdentifier;
        balance : shared () -> async Ledger.Tokens;
        transfer : shared (amount : Ledger.Tokens, to : Ledger.AccountIdentifier) -> async Ledger.TransferResult;
    };

    public type Main = Admin and Account and Launchpad.Interface;
};
