module Ledger {
    // Amount of tokens, measured in 10^-8 of a token.
    public type Tokens = {
        e8s : Nat64;
    };

    // Number of nanoseconds from the UNIX epoch in UTC timezone.
    type TimeStamp = {
        timestamp_nanos: Nat64;
    };

    // AccountIdentifier is a 32-byte array.
    // The first 4 bytes is big-endian encoding of a CRC32 checksum of the last 28 bytes.
    public type AccountIdentifier = Blob;

    // Subaccount is an arbitrary 32-byte byte array.
    // Ledger uses subaccounts to compute the source address, which enables one
    // principal to control multiple ledger accounts.
    type SubAccount = Blob;


    // Sequence number of a block produced by the ledger.
    type BlockIndex = Nat64;

    // Arguments for the `account_balance` call.
    public type AccountBalanceArgs = {
        account: AccountIdentifier;
    };

    // An arbitrary number associated with a transaction.
    // The caller can set it in a `transfer` call as a correlation identifier.
    type Memo = Nat64;

    // Arguments for the `transfer` call.
    public type TransferArgs = {
        // Transaction memo.
        // See comments for the `Memo` type.
        memo: Memo;
        // The amount that the caller wants to transfer to the destination address.
        amount: Tokens;
        // The amount that the caller pays for the transaction.
        // Must be 10000 e8s.
        fee: Tokens;
        // The subaccount from which the caller wants to transfer funds.
        // If null, the ledger uses the default (all zeros) subaccount to compute the source address.
        // See comments for the `SubAccount` type.
        from_subaccount: ?SubAccount;
        // The destination account.
        // If the transfer is successful, the balance of this address increases by `amount`.
        to: AccountIdentifier;
        // The point in time when the caller created this request.
        // If null, the ledger uses current IC time as the timestamp.
        created_at_time: ?TimeStamp;
    };

    type TransferError = {
        // The fee that the caller specified in the transfer request was not the one that ledger expects.
        // The caller can change the transfer fee to the `expected_fee` and retry the request.
        #BadFee : { expected_fee : Tokens; };
        // The account specified by the caller doesn't have enough funds.
        #InsufficientFunds : { balance: Tokens; };
        // The request is too old.
        // The ledger only accepts requests created within 24 hours window.
        // This is a non-recoverable error.
        #TxTooOld : { allowed_window_nanos: Nat64 };
        // The caller specified `created_at_time` that is too far in future.
        // The caller can retry the request later.
        #TxCreatedInFuture;
        // The ledger has already executed the request.
        // `duplicate_of` field is equal to the index of the block containing the original transaction.
        #TxDuplicate : { duplicate_of: BlockIndex; }
    };

    public type TransferResult = {
        #Ok : BlockIndex;
        #Err : TransferError;
    };

    public type Interface = actor {
        // Transfers tokens from a subaccount of the caller to the destination address.
        // The source address is computed from the principal of the caller and the specified subaccount.
        // When successful, returns the index of the block containing the transaction.
        transfer : shared (TransferArgs) -> async (TransferResult);

        // Returns the amount of Tokens on the specified account.
        account_balance : query (AccountBalanceArgs) -> async (Tokens);
    };
}
