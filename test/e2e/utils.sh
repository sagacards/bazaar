#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NC=$(tput sgr0)

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

replace() {
    sed -i 's/let version = [0-9]*;/let version = '$1';/' ./src/main.mo
}

deploy() {
    DFX_MOC_PATH="$(vessel bin)/moc" dfx -q deploy mock_ledger
    ledgerId=$(dfx canister id mock_ledger)
    DFX_MOC_PATH="$(vessel bin)/moc" dfx -q deploy progenitus --argument "(\"$ledgerId\")"
}
