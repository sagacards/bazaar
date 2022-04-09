import Result "mo:base/Result";

import Event "Events/Event";

module {
    public type MintError = {
        // Indicates that there are no NFTs available anymore.
        #NoneAvailable;
        #TryCatchTrap;
    };

    public type Interface = actor {
        // 🛑 NFT ADMIN RESTRICTED

        // Creates a new event and returns the storage index.
        launchpadEventCreate : shared (event : Event.Data) -> async Nat;
        // Overwrites the event at the given storage index.
        launchpadEventUpdate : shared (index : Nat, event : Event.Data) -> async ();

        // 🚀 LAUNCHPAD RESTRICTED

        // Returns the total available nfts.
        launchpadTotalAvailable : query (index : Nat) -> async Nat;
        // Allows the launchpad to mint a (random) NFT to the given principal.
        // @returns : the NFT id.
        // @traps   : not authorized.
        // @err     : no nfts left...
        launchpadMint : shared (to : Principal) -> async Result.Result<Nat, MintError>;
    };
};
