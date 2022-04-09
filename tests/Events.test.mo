import Principal "mo:base/Principal";

import Events "../src/Events";
import Event "../src/Events/Event";

let nft0 = Principal.fromText("aaaaa-aa");
let nft1 = Principal.fromText("utpk4-hka");

let lp = Events.Class({
    events = [];
});

let emptyDetails = {
    iconImageUrl           = "";
    bannerImageUrl         = "";
    previewImageUrl        = "";
    descriptionMarkdownUrl = "";
};

func event(name : Text, accessType : Event.Access) : Event.Data = {
    name;
    description = "";
    startsAt    = 0;
    endsAt      = 1;
    price       = { e8s = 0 };
    accessType;
    details     = emptyDetails;
};

do {
    let i = lp.createEvent(nft0, event("e0", #Public));
    assert(i == 0);
    let es = lp.getEvents([nft0]);
    assert(es == lp.getAllEvents());
    assert(es.size() == 1);
    assert(es[0].0 == nft0);
    assert(es[0].1.name == "e0");
    // etc.
};

do {
    let a = Principal.fromText("2ibo7-dia");
    let b = Principal.fromText("ihmrf-7yaaa");
    let c = Principal.fromText("75a5s-eqaaa-aa");
    let d = Principal.fromText("efcn6-haaaa-aaa");
    let e = Principal.fromText("yyrpo-hiaaa-aaaaa");

    let i = lp.createEvent(nft1, event("e1", #Private([(a, ?-1),  (b, ?5), (c, ?2), (d, ?1), (e, null)])));
    assert(i == 0);
    let es = lp.getEvents([nft1]);
    assert(es != lp.getAllEvents());
    assert(es.size() == 1);
    assert(es[0].0 == nft1);
    assert(es[0].1.name == "e1");
};
