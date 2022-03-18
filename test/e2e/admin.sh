#!/bin/bash
# The following test checks whether the admin list is resistant to upgrades.

. ./test/e2e/utils.sh

bold "| Starting replica..."
dfx start --background --clean > /dev/null 2>&1

dfx identity use user
userPrincipal=$(dfx identity get-principal)

dfx identity use admin
adminPrincipal=$(dfx identity get-principal)

add_version
deploy

admin1="$(dfx canister call progenitus getAdmins)"
dfx canister call progenitus addAdmin "(principal \"$userPrincipal\")"
admin2="$(dfx canister call progenitus getAdmins)"

notEqual "$admin1" "$admin2"

replace_version "1"
redeploy

equal "$admin2" "$(dfx canister call progenitus getAdmins)"

remove_version
dfx -q stop > /dev/null 2>&1
