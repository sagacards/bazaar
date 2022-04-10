import 'isomorphic-fetch';
import { readFileSync } from "fs";
import { ActorSubclass, Identity } from '@dfinity/agent';

import { createActor } from "./actor";
import { idlFactory as pIDL } from './declarations/progenitus/progenitus.did';
import { Rex } from "./declarations/progenitus/progenitus.did.d";
import { idlFactory as mlIDL } from './declarations/mock_ledger/mock_ledger.did';
import { MockLedger } from "./declarations/mock_ledger/mock_ledger.did.d";

const canisters = JSON.parse(readFileSync(`${__dirname}/../.dfx/local/canister_ids.json`).toString());
const pCID = canisters.progenitus.local;
const mlCID = canisters.mock_ledger.local;

export function launchpadActor(identity? : Identity) : ActorSubclass<Rex> {
    return createActor(pCID, pIDL, { identity });
};

export function mockLedgerActor(identity? : Identity) : ActorSubclass<MockLedger> {
    return createActor(mlCID, mlIDL, { identity });
};