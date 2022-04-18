import { IDL } from "@dfinity/candid";
export const idlFactory : IDL.InterfaceFactory = ({ IDL }) => {
  const Tokens = IDL.Record({ 'e8s' : IDL.Nat64 });
  const Time = IDL.Int;
  const EventName = IDL.Text;
  const Spots = IDL.Opt(IDL.Int);
  const Allowlist = IDL.Vec(IDL.Tuple(IDL.Principal, Spots));
  const Access = IDL.Variant({ 'Private' : Allowlist, 'Public' : IDL.Null });
  const URL = IDL.Text;
  const CollectionDetails = IDL.Record({
    'descriptionMarkdownUrl' : URL,
    'iconImageUrl' : URL,
    'bannerImageUrl' : URL,
    'previewImageUrl' : URL,
  });
  const Data = IDL.Record({
    'startsAt' : Time,
    'name' : EventName,
    'description' : IDL.Text,
    'accessType' : Access,
    'details' : CollectionDetails,
    'price' : Tokens,
    'endsAt' : Time,
  });
  const Event = IDL.Tuple(IDL.Principal, Data, IDL.Nat);
  const Events = IDL.Vec(Event);
  const Error = IDL.Variant({
    'NotInAllowlist' : IDL.Null,
    'TokenNotFound' : IDL.Principal,
    'IndexNotFound' : IDL.Nat,
  });
  const Result__1 = IDL.Variant({ 'ok' : IDL.Int, 'err' : Error });
  const Result_1 = IDL.Variant({ 'ok' : Data, 'err' : Error });
  const AccountIdentifier = IDL.Vec(IDL.Nat8);
  const BlockIndex = IDL.Nat64;
  const TransferError = IDL.Variant({
    'TxTooOld' : IDL.Record({ 'allowed_window_nanos' : IDL.Nat64 }),
    'BadFee' : IDL.Record({ 'expected_fee' : Tokens }),
    'TxDuplicate' : IDL.Record({ 'duplicate_of' : BlockIndex }),
    'TxCreatedInFuture' : IDL.Null,
    'InsufficientFunds' : IDL.Record({ 'balance' : Tokens }),
  });
  const MintError = IDL.Variant({
    'NoneAvailable' : IDL.Null,
    'Refunded' : IDL.Null,
    'TryCatchTrap' : IDL.Text,
    'NoMintingSpot' : IDL.Null,
    'Transfer' : TransferError,
    'Events' : Error,
  });
  const MintResult = IDL.Variant({ 'ok' : IDL.Nat, 'err' : MintError });
  const TransferResult = IDL.Variant({
    'Ok' : BlockIndex,
    'Err' : TransferError,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : Error });
  const Rex = IDL.Service({
    'addAdmin' : IDL.Func([IDL.Principal], [], ['oneway']),
    'balance' : IDL.Func([], [Tokens], []),
    'createEvent' : IDL.Func([Data], [IDL.Nat], []),
    'currentlyMinting' : IDL.Func([], [IDL.Nat], ['query']),
    'getAdmins' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'getAllEvents' : IDL.Func([], [Events], ['query']),
    'getAllowlistSpots' : IDL.Func(
        [IDL.Principal, IDL.Nat],
        [Result__1],
        ['query'],
      ),
    'getEvent' : IDL.Func([IDL.Principal, IDL.Nat], [Result_1], ['query']),
    'getEvents' : IDL.Func([IDL.Vec(IDL.Principal)], [Events], ['query']),
    'getEventsOfToken' : IDL.Func([IDL.Principal], [IDL.Vec(Data)], ['query']),
    'getOwnEvents' : IDL.Func([], [IDL.Vec(Data)], ['query']),
    'getPersonalAccount' : IDL.Func([], [AccountIdentifier], ['query']),
    'mint' : IDL.Func([IDL.Principal, IDL.Nat], [MintResult], []),
    'removeAdmin' : IDL.Func([IDL.Principal], [], ['oneway']),
    'removeEvent' : IDL.Func([IDL.Principal, IDL.Nat], [], ['oneway']),
    'transfer' : IDL.Func([Tokens, AccountIdentifier], [TransferResult], []),
    'updateEvent' : IDL.Func([IDL.Nat, Data], [Result], []),
  });
  return Rex;
};
