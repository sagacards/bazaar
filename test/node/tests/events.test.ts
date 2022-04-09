import { Ed25519KeyIdentity } from "@dfinity/identity";
import { launchpadActor } from "../src";

function toHexString(byteArray: Array<number>) {
    return Array.from(byteArray, function (byte) {
        return ('0' + (byte & 0xFF).toString(16)).slice(-2);
    }).join('')
}

describe("Events", () => {
    it("Print random account...", async () => {
        const actor = launchpadActor(Ed25519KeyIdentity.generate())
        const account = await actor.getPersonalAccount();
        console.log(toHexString(account));
    });
});
