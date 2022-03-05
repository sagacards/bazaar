import AId "mo:principal/blob/AccountIdentifier";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Binary "mo:encoding/Binary";
import CRC32 "mo:hash/CRC32";
import Principal "mo:base/Principal";
import SHA224 "mo:crypto/SHA/SHA224";

/// Account (~ Account Identifier)
module Account {
    public type Account = AId.AccountIdentifier;

    public func zeroAccount(
        canisterId : Principal
    ) : Blob {
        AId.fromPrincipal(canisterId, null);
    };

    public func getAccount(
        canisterId  : Principal,
        principalId : Principal,
    ) : Blob {
        let subAccount = principal2SubAccount(principalId);
        AId.fromPrincipal(canisterId, ?subAccount);
    };

    public let toText   = AId.toText;
    public let fromText = AId.fromText;

    public func principal2SubAccount(p : Principal) : AId.SubAccount {
        let hash  = SHA224.sum(Blob.toArray(Principal.toBlob(p)));    // [28]
        let check = Binary.BigEndian.fromNat32(CRC32.checksum(hash)); // [04]
        Array.tabulate<Nat8>(32, func (i : Nat) : Nat8 {
            if (i < 4) return check[i];
            hash[i - 4];
        });
    };
};
