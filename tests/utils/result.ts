import { assert } from "chai";
import { Error, MintError } from "../../lib/declarations/bazaar/bazaar.did.d";

type ResultErr = { 'err' : MintError } | { 'err' : Error };
export type Result<T> = { 'ok' : T } | ResultErr;

export function isOk<T>(r : Result<T>) : T {
    assert.isTrue("ok" in r);
    return (<{ 'ok' : T}>r).ok;
};
