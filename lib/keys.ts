import { Identity } from "@dfinity/agent";
import { Ed25519KeyIdentity } from "@dfinity/identity";
import { Principal } from "@dfinity/principal";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "fs";
import { sha224 } from "js-sha256";
import crc32 from "./utils/crc32";

export const DIR = `${__dirname}/../keys`
export const PATH = `${DIR}/keys.json`;

export function fetchIdentity(name: string): Identity {
    if (!existsSync(PATH)) throw Error(`'${PATH}' does not exist.`);
    const keys = JSON.parse(readFileSync(PATH).toString());
    if (!keys[name]) throw Error(`Key with name ${name} not found.`);
    return Ed25519KeyIdentity.fromParsedJson(JSON.parse(keys.admin));
};

export function generateKey(name: string): Identity {
    if (!existsSync(DIR)) mkdirSync(DIR, { recursive: true });
    if (!existsSync(PATH)) writeFileSync(PATH, "{}", { flag: "wx" });

    const keys = JSON.parse(readFileSync(PATH).toString());

    if (!keys[name]) {
        const key = Ed25519KeyIdentity.generate();
        keys["admin"] = JSON.stringify(key);
        writeFileSync(PATH, JSON.stringify(keys));
        return key;
    }
    throw Error(`There is already a key with the name ${name} in keys.json...`);
};

export function getAccountIdentifier(principal: Principal, subAccount?: Uint8Array): Array<number> {
    const array = new Uint8Array([
        ...Buffer.from("\x0Aaccount-id"),
        ...principal.toUint8Array(),
        ...getSubAccountArray(subAccount)
    ]);
    const hash = new Uint8Array(sha224.create().update(array).array());
    return Array.from(new Uint8Array([
        ...crc32(hash),
        ...hash
    ]));
};

const ZERO_SUBACCOUNT = new Uint8Array(32).fill(0);

function getSubAccountArray(subAccount?: Uint8Array): Uint8Array {
    if (!subAccount) return ZERO_SUBACCOUNT;
    return new Uint8Array([
        ... new Uint8Array(32 - subAccount.length),
        ...subAccount
    ]);
};
