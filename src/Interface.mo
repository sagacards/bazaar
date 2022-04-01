import DIP721 "mo:dip/DIP721";

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
        getPrice : query () -> async Ledger.Tokens;
        getPersonalAccount : query () -> async Ledger.AccountIdentifier;
        balance : shared () -> async Ledger.Tokens;
        transfer : shared (amount : Ledger.Tokens, to : Ledger.AccountIdentifier) -> async Ledger.TransferResult;
    };

    public type Main = Admin and Account and Launchpad.Interface;
};
