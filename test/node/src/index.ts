import 'isomorphic-fetch';
import { readFileSync } from "fs";
import { createActor } from "./actor";
import { idlFactory } from './declarations/progenitus/progenitus.did';
import { Rex } from "./declarations/progenitus/progenitus.did.d";
import { ActorSubclass, Identity } from '@dfinity/agent';

const canisters = JSON.parse(readFileSync("../../.dfx/local/canister_ids.json").toString());
const canisterId = canisters.progenitus.local;

export function launchpadActor(identity : Identity) : ActorSubclass<Rex> {
    return createActor(canisterId, idlFactory, { identity });
};
