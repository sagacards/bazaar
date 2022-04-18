import 'isomorphic-fetch';
import { readFileSync } from "fs";
import { ActorSubclass, Identity } from '@dfinity/agent';

import { createActor } from "./actor";
import { idlFactory as pIDL } from './declarations/bazaar/bazaar.did';
import { Rex } from "./declarations/bazaar/bazaar.did.d";
import { idlFactory as mlIDL } from './declarations/mock_ledger/mock_ledger.did';
import { MockLedger } from "./declarations/mock_ledger/mock_ledger.did.d";
import { idlFactory as nftIDL } from './declarations/mock_nft/mock_nft.did';
import { MockNFT } from "./declarations/mock_nft/mock_nft.did.d";
import { Principal } from '@dfinity/principal';

const canisters = JSON.parse(readFileSync(`${__dirname}/../.dfx/local/canister_ids.json`).toString());

const bazaarCID = canisters.bazaar.local;
export const bazaarPrincipal = Principal.fromText(bazaarCID);
const ledgerCID = canisters.mock_ledger.local;
export const ledgerPrincipal = Principal.fromText(ledgerCID);
const nftCID = canisters.mock_nft.local;
export const nftPrincipal = Principal.fromText(nftCID);

export function launchpadActor(identity? : Identity) : ActorSubclass<Rex> {
    return createActor(bazaarCID, pIDL, { identity });
};

export function mockLedgerActor(identity? : Identity) : ActorSubclass<MockLedger> {
    return createActor(ledgerCID, mlIDL, { identity });
};

export function mockNFTActor(identity? : Identity) : ActorSubclass<MockNFT> {
    return createActor(nftCID, nftIDL, { identity });
};
