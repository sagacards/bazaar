import 'dotenv/config';
import { Actor, ActorSubclass, HttpAgent, HttpAgentOptions } from "@dfinity/agent";
import { IDL } from "@dfinity/candid";
import { Principal } from "@dfinity/principal";

export function createActor<T>(canisterId: string | Principal, idlFactory: IDL.InterfaceFactory, options: HttpAgentOptions) : ActorSubclass<T> {
    const agent = new HttpAgent({
        host: process.env.HOST,
        ...options
    });

    agent.fetchRootKey().catch(err => {
        console.warn("Unable to fetch root key. Check to ensure that your local replica is running");
        console.error(err);
    });

    return Actor.createActor(idlFactory, {
        agent,
        canisterId,
    });
};
