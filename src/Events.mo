import Ledger "Ledger";

module {
    public type Event = {
        #PublicSale : EventPublicSale;
    };

    public type EventPublicSale = {
        name        : Text;
        description : Text;
        starts_at   : Int;
        ends_at     : Int;
        price       : Ledger.Tokens;
    };
};
