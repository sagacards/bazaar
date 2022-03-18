#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NC=$(tput sgr0)

dfx identity new admin > /dev/null 2>&1
dfx identity new user  > /dev/null 2>&1

bold() {
    tput bold
    echo $1
    tput sgr0
}

equal() {
    if [ "$1" = "$2" ]; then
        echo "${GREEN}OK${NC}"
    else
        echo "${RED}NOK${NC}: expected ${2}, got ${1}"
        dfx -q stop > /dev/null 2>&1
        exit 1
    fi
}

notEqual() {
    if [ "$1" = "$2" ]; then
        echo "${RED}NOK${NC}: got ${1} twice"
        dfx -q stop > /dev/null 2>&1
        exit 1
    else
        echo "${GREEN}OK${NC}"
    fi
}

add_version() {
    sed -i '' -e 's/this {/this { public query func e2e() : async () {};/' ./src/main.mo
}

replace_version() {
    sed -i '' -e 's/public query func e2e[0-9]*() : async () {};/public query func e2e'$1'() : async () {};/' ./src/main.mo
}

remove_version() {
    sed -i '' -e 's/ public query func e2e[0-9]*() : async () {};//' ./src/main.mo
}

redeploy() {
    echo "Redeploying..."
    echo "$(dfx canister info progenitus)"
    ledgerId=$(dfx canister id mock_ledger)
    nftId=$(dfx canister id mock_nft)
    echo "yes" | DFX_MOC_PATH="$(vessel bin)/moc" dfx -q deploy progenitus --argument "(\"$ledgerId\", \"$nftId\")"
    echo "$(dfx canister info progenitus)"
}

deploy() {
    echo "Deploying..."
    DFX_MOC_PATH="$(vessel bin)/moc" dfx -q deploy mock_ledger
    DFX_MOC_PATH="$(vessel bin)/moc" dfx -q deploy mock_nft
    ledgerId=$(dfx canister id mock_ledger)
    nftId=$(dfx canister id mock_nft)
    DFX_MOC_PATH="$(vessel bin)/moc" dfx -q deploy progenitus --argument "(\"$ledgerId\", \"$nftId\")"
}
