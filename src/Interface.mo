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

    public type MintResult = Result.Result<Nat, MintError>;

    public type MintError = {
        /// Describes a ledger transfer error.
        #Transfer : Ledger.TransferError;
        /// Indicates that you are not in the allowlist and are not allowed to mint.
        #NoMintingSpot;
        /// Indicates that no more NFTs are available.
        #NoneAvailable;
        /// Indicates that an external services trapped...
        #TryCatchTrap;
    };

    /// 🟢 Public functions.
    public type Account = actor {
        getAllowlistSpots : query (token : Principal, index : Nat) -> async ?Int;
        getPersonalAccount : query () -> async Ledger.AccountIdentifier;
        balance : shared () -> async Ledger.Tokens;
        transfer : shared (amount : Ledger.Tokens, to : Ledger.AccountIdentifier) -> async Ledger.TransferResult;
        mint : shared (token : Principal, index : Nat) -> async MintResult;
    };

    public type Main = Admin and Account and Events.Interface;
};
