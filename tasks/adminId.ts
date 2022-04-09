import { fetchIdentity } from "../lib/keys";

console.log(fetchIdentity("admin").getPrincipal().toString());
