import Blob "mo:base/Blob";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";

import AccountIdentifier "../AccountIdentifier";
import Ledger "../Ledger";

module {
    /// Represents a simple ledger (mapping from sub account to amount of tokens).
    public type Locks = HashMap.HashMap<Ledger.SubAccount, Ledger.Tokens>;

    /// Creates a new empty locks ledger.
    public func empty(capacity : Nat) : Locks = HashMap.HashMap<Ledger.SubAccount, Ledger.Tokens>(
        capacity, Blob.equal, Blob.hash
    );

    public module Locks = {
        /// Returns the amount of tokens that is locked for the given sub account.
        ///
        /// @internal: should not be exposed.
        public func lockedBalance(
            // The locks ledger.
            locks : Locks, 
            // The sub account of the requested locked balance.
            subAccount : Ledger.SubAccount
        ) : Ledger.Tokens = switch (locks.get(subAccount)) {
            case (null) return { e8s = 0 };
            case (? locked) locked;
        };

        /// Locks the given amount of tokens for the given account (principal + sub account). The locked amount is 
        /// validated at the (given) ledger, if insufficient funds are available an error will be returned. The (total)
        /// locked amount will be returned if the lock request was processed successfully.
        ///
        /// @internal: should not be exposed.
        public func lock(
            // The locks ledger.
            locks : Locks, 
            // A reference to the ledger to validate locked funds.
            ledger : Ledger.Interface, 
            // The base principal of the account (i.e. canister id).
            principal : Principal, 
            // The sub account of the respective account.
            subAccount : Ledger.SubAccount, 
            // The amount to be locked.
            amount : Ledger.Tokens
        ) : async Result.Result<Ledger.Tokens, Ledger.TransferError> {
            let locked = switch (locks.get(subAccount)) {
                case (null) {
                    // No tokens locked yet.
                    locks.put(subAccount, amount);
                    amount;
                };
                case (? { e8s }) {
                    // Increase the amount of locked tokens.
                    let new = { e8s = e8s + amount.e8s };
                    locks.put(subAccount, new);
                    new;
                };
            };
            // Reconstruct the account.
            let account = AccountIdentifier.fromPrincipal(principal, ?Blob.toArray(subAccount));
            // Request the actual balance.
            let balance = await ledger.account_balance({ account });
            if (balance.e8s < locked.e8s) {
                // Revert the lock if not enough balance.
                // This should prevent reentrancy (e.g. fake account balances).
                unlock(locks, subAccount, amount);
                return #err(#InsufficientFunds({ balance }));
            };
            #ok(locked);
        };

        /// Transfers locked tokens, if succeeded, unlock can be called.
        /// NOTE: the fee will be deducted from the amount!
        ///
        /// @pre: lock balance.
        /// @internal: should not be exposed.
        /// @post: unlock balance.
        public func transferLocked(
            // The locks ledger.
            locks : Locks,
            // A reference to the ledger to make the transfer.
            ledger : Ledger.Interface,
            // The sub account to transfer the locked tokens from.
            subAccount : Ledger.SubAccount,
            // The amount of tokens to be transferred.
            amount : Ledger.Tokens,
            // The receiving account.
            to : Ledger.AccountIdentifier
        ) : async Ledger.TransferResult {
            // Check if the account has enough locked balance.
            let balance = lockedBalance(locks, subAccount);
            if (balance.e8s < amount.e8s) return #Err(#InsufficientFunds({ balance }));
            await ledger.transfer({
                memo            = 0;
                amount          = { e8s = amount.e8s - 10_000};
                fee             = { e8s = 10_000 };
                from_subaccount = ?subAccount;
                to;
                created_at_time = null;
            });
        };

        /// Transfers (unlocked) tokens to the given account.
        ///
        /// @external: can be exposed, prevents users to transfer locked balances.
        public func transfer(
            // The locks ledger.
            locks : Locks,
            // A reference to the ledger to make the transfer.
            ledger : Ledger.Interface,
            // The base principal of the account (i.e. canister id).
            principal : Principal,
            // The sub account to transfer the locked tokens from.
            subAccount : Ledger.SubAccount,
            // The amount of tokens to be transferred.
            amount : Ledger.Tokens,
            // The receiving account.
            to : Ledger.AccountIdentifier
        ) : async Ledger.TransferResult {
            let locked  = lockedBalance(locks, subAccount);
            // Reconstruct the account.
            let account = AccountIdentifier.fromPrincipal(principal, ?Blob.toArray(subAccount));
            // Request the actual balance.
            let balance = await ledger.account_balance({ account });

            // Check whether there is enough (unlocked) tokens.
            let available = balance.e8s - locked.e8s;
            if (available < amount.e8s + 10_000) return #Err(#InsufficientFunds({ balance = { e8s = available } }));
            await ledger.transfer({
                memo            = 0;
                amount          = { e8s = amount.e8s };
                fee             = { e8s = 10_000 };
                from_subaccount = ?subAccount;
                to;
                created_at_time = null;
            });
        };

        /// Unlocks the given amount for the given sub account.
        ///
        /// @internal: should not be exposed.
        public func unlock(
            // The locks ledger.
            locks : Locks,
            // The sub account to unlock tokens for.
            subAccount : Ledger.AccountIdentifier,
            // The amount of tokens to unlock.
            amount : Ledger.Tokens
        ) {
            switch (locks.get(subAccount)) {
                case (null) assert(false); // unreachable.
                case (? { e8s }) {
                    if (e8s == amount.e8s) {
                        // Unlock the whole balance.
                        locks.delete(subAccount);
                        return;
                    };

                    if (e8s < amount.e8s) assert(false); // unreachable.
                    let new = { e8s = e8s - amount.e8s };
                    locks.put(subAccount, new);
                };
            };
        };
    };
};
