import AccountIdentifier "mo:principal/blob/AccountIdentifier";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Binary "mo:encoding/Binary";
import CRC32 "mo:hash/CRC32";
import Principal "mo:base/Principal";
import SHA224 "mo:crypto/SHA/SHA224";

import Ledger "Ledger";

module {
    /// Returns the zero account of the given principal identifier.
    public func zeroAccount(
        principalId : Principal
    ) : Ledger.AccountIdentifier {
        AccountIdentifier.fromPrincipal(principalId, null);
    };

    /// Returns a sub account of the given canister based on the given principal id.
    public func getAccount(
        canisterId  : Principal,
        principalId : Principal,
    ) : Ledger.AccountIdentifier {
        let subAccount = principal2SubAccount(principalId);
        AccountIdentifier.fromPrincipal(canisterId, ?subAccount);
    };

    public let toText        = AccountIdentifier.toText;
    public let fromText      = AccountIdentifier.fromText;
    public let fromPrincipal = AccountIdentifier.fromPrincipal;

    // Converts the given principal to a sub account (32 bytes).
    // First 4 bytes are the checksum of the SHA224 hash of the principal.
    public func principal2SubAccount(p : Principal) : AccountIdentifier.SubAccount {
        assert(not Principal.isAnonymous(p));

        let hash  = SHA224.sum(Blob.toArray(Principal.toBlob(p)));    // [28]
        let check = Binary.BigEndian.fromNat32(CRC32.checksum(hash)); // [04]
        Array.tabulate<Nat8>(32, func (i : Nat) : Nat8 {
            if (i < 4) return check[i];
            hash[i - 4];
        });
    };
};
