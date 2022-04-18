import { ActorSubclass, Identity } from "@dfinity/agent";
import { Ed25519KeyIdentity } from "@dfinity/identity";
import { launchpadActor, mockLedgerActor, mockNFTActor } from "../lib";
import { MockLedger } from "../lib/declarations/mock_ledger/mock_ledger.did.d";
import { MockNFT } from "../lib/declarations/mock_nft/mock_nft.did.d";
import { Rex } from "../lib/declarations/progenitus/progenitus.did.d";
import { fetchIdentity } from "../lib/keys";

type Account = {
    key: Identity
    launchpad: ActorSubclass<Rex>
    ledger: ActorSubclass<MockLedger>
    nft: ActorSubclass<MockNFT>
};

export const users = new Array(20).fill(Ed25519KeyIdentity.generate()).map((key) => {
    return {
        key,
        launchpad: launchpadActor(key),
        ledger: mockLedgerActor(key),
        nft: mockNFTActor(key)
    }
});

const adminKey = fetchIdentity("admin");
export const admin : Account = {
    key: fetchIdentity("admin"),
    launchpad: launchpadActor(adminKey),
    ledger: mockLedgerActor(adminKey),
    nft: mockNFTActor(adminKey)
};

export async function mint(to: Array<number>, e8s: bigint) {
    await admin.ledger.mint({ to, amount: { e8s } });
};
