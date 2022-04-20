import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Int "mo:base/Int";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";

import Events "../src/Events";

func tokenN(index : Nat) : Principal = token(Nat8.fromNat(index));
func token(index : Nat8) : Principal {
    Principal.fromBlob(Blob.fromArray([
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, index,
        0x01
    ]))
};

func user(index : Nat) : Principal = tokenN(100 + index);

func event(access : Events.Access, e8s : Nat64) : Events.Data = eventN(token(0), 0, access, e8s);

func eventN(
    token : Principal, index : Nat, // Only used to construct the name.
    access : Events.Access, e8s : Nat64
) : Events.Data = {
    accessType  = access;
    description = "";
    details = {
        bannerImageUrl         = "";
        descriptionMarkdownUrl = "";
        iconImageUrl           = "";
        previewImageUrl        = "";
    };
    endsAt   = 0;
    name     = eventName(token, index);
    price    = { e8s };
    startsAt = 0;
};

func eventName(token : Principal, index : Nat) : Text = Principal.toText(token) # ":" # Int.toText(index);

// CRUD.
do {
    let events : Events.Events_ = Events.Events.fromStable([]);

    // Add an event.
    let index = Events.Events.add(events, token(0), event(#Public, 10_000));
    assert(index == 0);
    assert(events.size() == 1);

    // Get the event.
    switch (Events.Events.getEventIndexData(events, token(0), index)) {
        case (#err(_)) assert(false);
        case (#ok(data)) {
            assert(data.accessType == #Public);
            assert(data.price.e8s == 10_000);
        };
    };

    // Replace the event.
    switch (Events.Events.replace(events, token(0), index, event(#Public, 0))) {
        case (#err(_)) assert(false);
        case (_) {};
    };
    assert(events.size() == 1);

    // Get the (replaced) event.
    switch (Events.Events.getEventIndexData(events, token(0), index)) {
        case (#err(_))  assert(false);
        case (#ok(data)) assert(data.price.e8s == 0);
    };

    // Delete the event.
    Events.Events.remove(events, token(0), index);
    assert(events.size() == 1);
    assert(Events.Events.toStable(events) == []);
};

// Get Event Data
do {
    let T_AMOUNT = 10;
    let E_AMOUNT = 3;

    let events : Events.Events_ = Events.Events.fromStable([]);
    for (i in Iter.range(0, T_AMOUNT - 1)) {
        for (j in Iter.range(0, E_AMOUNT - 1)) {
            let tk = tokenN(i);
            let index = Events.Events.add(events, tk, eventN(tk, j, #Public, 0));
            assert(index == j);
        };
    };
    assert(Events.Events.toStableFilter(events, [token(0), token(1), token(2)]).size() == 3 * E_AMOUNT);
    assert(Events.Events.toStable(events).size() == T_AMOUNT * E_AMOUNT);

    let tk = token(0);
    switch (Events.Events.getEventData(events, tk)) {
        case (#err(_)) assert(false);
        case (#ok(data)) {
            assert(data.size() == E_AMOUNT);
            var i = 0;
            for (d in data.vals()) {
                assert(d.name == eventName(tk, i));
                i += 1;
            };
        };
    };
    switch (Events.Events.getEventIndexData(events, tk, 1)) {
        case (#err(_))   assert(false);
        case (#ok(data)) assert(data.name == eventName(tk, 1));
    };

    // Spots...
    let data = switch (Events.Events.getEventIndexData_(events, tk, 0)) {
        case (#err(_)) {
            assert(false);
            loop {};
        };
        case (#ok(data)) data;
    };
    assert(data.metadata.price == { e8s = 0 });
    assert(Events.Access.getSpots(data.access, user(0)) == -1);

    // Remove a spot.
    assert(Events.Access.removeSpot(data.access, user(0)) == #ok(-1));

    // Add a spot.
    Events.Access.addSpot(data.access, user(0));
    assert(Events.Access.getSpots(data.access, user(0)) == -1);
};

// Private Sale
do {
    let U_AMOUNT = 10;
    let events : Events.Events_ = Events.Events.fromStable([]);

    let tk = token(0);
    let spots = Buffer.Buffer<(Principal, ?Int)>(U_AMOUNT);
    for (i in Iter.range(0, U_AMOUNT - 1)) spots.add(user(i), ?(i+1));
    let index = Events.Events.add(events, tk, event(#Private(spots.toArray()), 0));
    let data = switch (Events.Events.getEventIndexData_(events, tk, 0)) {
        case (#err(_)) {
            assert(false);
            loop {};
        };
        case (#ok(data)) data;
    };
    for (i in Iter.range(0, U_AMOUNT - 1)) assert(Events.Access.getSpots(data.access, user(i)) == i+1);

    for (i in Iter.range(0, U_AMOUNT - 1)) {
        assert(Events.Access.removeSpot(data.access, user(i)) == #ok(0));
        for (j in Iter.range(i + 1, U_AMOUNT - 1)) {
            assert(Events.Access.removeSpot(data.access, user(j)) == #ok(j-i));
        };
    };

    // No data.
    switch (Events.Events.getEventIndexData(events, tk, 0)) {
        case (#err(_))   assert(false);
        case (#ok(data)) assert(data.accessType == #Private([]));
    };

    // Restore original data.
    for (i in Iter.range(0, U_AMOUNT - 1)) {
        for (j in Iter.range(0, i)) Events.Access.addSpot(data.access, user(i));
    };
    switch (Events.Events.getEventIndexData(events, tk, 0)) {
        case (#err(_))   assert(false);
        case (#ok(data)) switch (data.accessType) {
            case (#Public) assert(false);
            case (#Private(list)) {
                for ((p, n) in list.vals()) {
                    var found = false;
                    label l for ((q, m) in spots.vals()) {
                        if (p == q  and n == m) {
                            found := true;
                            break l;
                        };
                    };
                    assert(found);
                };
            };
        };
    };
};
