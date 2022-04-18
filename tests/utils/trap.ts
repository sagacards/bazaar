import { assert } from "chai";

export async function trap(p: Promise<any>, msg?: RegExp) {
    const errorMessage = msg ? msg : /assertion failed/;
    await p.then(() => {
        assert.fail()
    }).catch((e) => {
        assert.match(e.message, errorMessage);
    });
};
