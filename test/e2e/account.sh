#!/bin/bash
# The following test checks whether a user can transfer to and from its account.

. ./test/e2e/utils.sh

bold "| Starting replica..."
dfx start --background --clean > /dev/null 2>&1

dfx identity use user
userPrincipal=$(dfx identity get-principal)

dfx identity use admin
adminPrincipal=$(dfx identity get-principal)

deploy

userZeroAccount=$(dfx canister call mock_ledger zeroAccount "(principal \"$userPrincipal\")" | sed -n '2p' | sed 's/,//')
dfx canister call mock_ledger mint "(record { to = $userZeroAccount; amount = record { e8s = 100_00_000_000 : nat64 } })"

dfx identity use user

userAccount=$(dfx canister call progenitus getPersonalAccount | sed 's/^.\(.*\).$/\1/')

equal "$(dfx canister call mock_ledger account_balance "(record { account = $userZeroAccount })")" "(record { e8s = 10_000_000_000 : nat64 })"
dfx canister call mock_ledger transfer "(record { memo = 0; amount = record { e8s = 100_000_000 : nat64 }; fee = record { e8s = 10_000 : nat64 }; from_subaccount = null; to = $userAccount; created_at_time = null })"

equal "$(dfx canister call progenitus balance)" "(record { e8s = 100_000_000 : nat64 })"

dfx -q stop > /dev/null 2>&1
