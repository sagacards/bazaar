import DIP721 "mo:dip/DIP721";

import Account "Account";
import Ledger "Ledger";

module Interface {
    public type Interface = actor {
        /// 🛑
        addAdmin : shared (a : Principal) -> ();
        removeAdmin : shared (a : Principal) -> ();
        getAdmins : query () -> async [Principal];
        setPrice : shared (e8s : Ledger.Tokens) -> ();
        // NOTE: the tokens need to be owned by the principal of the canister.
        syncAvailableTokens : shared () -> ();

        /// 🟢
        getPrice : query () -> async Ledger.Tokens;
        getPersonalAccount : query () -> async Ledger.AccountIdentifier;
        balance : shared () -> async Ledger.Tokens;
        transfer : shared (amount : Ledger.Tokens, to : Ledger.AccountIdentifier) -> async Ledger.TransferResult; 
    };

    // DIP721Interface describes a subset of endpoints from the DIP721 standard on which the canister depends.
    public type DIP721Interface = actor {
        ownerTokenIds : query (owner : Principal) -> async DIP721.Result<[Nat]>;
    };
};
