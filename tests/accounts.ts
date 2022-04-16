import { Ed25519KeyIdentity } from "@dfinity/identity";
import { launchpadActor, mockLedgerActor, mockNFTActor } from "../lib";
import { fetchIdentity } from "../lib/keys";

export const users = new Array(2).fill(Ed25519KeyIdentity.generate()).map((k) => {
    return {
        key: k,
        launchpad: launchpadActor(k),
        ledger: mockLedgerActor(k),
        nft: mockNFTActor(k)
    }
});

const adminKey = fetchIdentity("admin");
export const admin = {
    key: fetchIdentity("admin"),
    launchpad: launchpadActor(adminKey),
    ledger: mockLedgerActor(adminKey),
    nft: mockNFTActor(adminKey)
};
