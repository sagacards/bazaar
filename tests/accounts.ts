import { ActorSubclass, Identity } from "@dfinity/agent";
import { Ed25519KeyIdentity } from "@dfinity/identity";
import { Principal } from "@dfinity/principal";
import { launchpadActor, mockLedgerActor, mockNFTActor } from "../lib";
import { MockLedger } from "../lib/declarations/mock_ledger/mock_ledger.did.d";
import { MockNFT } from "../lib/declarations/mock_nft/mock_nft.did.d";
import { Rex } from "../lib/declarations/bazaar/bazaar.did.d";
import { fetchIdentity } from "../lib/keys";

type Account = {
    key: Identity
    principal: Principal,
    launchpad: ActorSubclass<Rex>
    ledger: ActorSubclass<MockLedger>
    nft: ActorSubclass<MockNFT>
};

export const users : Account[] = [];
for (let i = 0; i < 20; i ++) {
    const key : Identity = Ed25519KeyIdentity.generate();
    users.push({
        key,
        principal: key.getPrincipal(),
        launchpad: launchpadActor(key),
        ledger: mockLedgerActor(key),
        nft: mockNFTActor(key)
    });
};

const adminKey = fetchIdentity("admin");
export const admin : Account = {
    key: adminKey,
    principal: adminKey.getPrincipal(),
    launchpad: launchpadActor(adminKey),
    ledger: mockLedgerActor(adminKey),
    nft: mockNFTActor(adminKey)
};

export async function mint(account: Account, e8s: bigint) {
    const to = await account.launchpad.getPersonalAccount();
    await admin.ledger.mint({ to, amount: { e8s } });
};

export async function mintAll(accounts : Array<Account>, e8s: bigint) {
    let args = [];
    for (const account of accounts) {
        const to = await account.launchpad.getPersonalAccount();
        args.push({ to, amount: { e8s }});
    };
    await admin.ledger.mintAll(args);
};
