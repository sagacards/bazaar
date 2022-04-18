import { IDL } from "@dfinity/candid";
export const idlFactory : IDL.InterfaceFactory = ({ IDL }) => {
  const AccountIdentifier = IDL.Vec(IDL.Nat8);
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
  const Tokens = IDL.Record({ 'e8s' : IDL.Nat64 });
  const Data = IDL.Record({
    'startsAt' : Time,
    'name' : EventName,
    'description' : IDL.Text,
    'accessType' : Access,
    'details' : CollectionDetails,
    'price' : Tokens,
    'endsAt' : Time,
  });
  const Error = IDL.Variant({
    'NotInAllowlist' : IDL.Null,
    'TokenNotFound' : IDL.Principal,
    'IndexNotFound' : IDL.Nat,
  });
  const Result__1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : Error });
  const MintError = IDL.Variant({
    'NoneAvailable' : IDL.Null,
    'TryCatchTrap' : IDL.Text,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Nat, 'err' : MintError });
  const BlockIndex = IDL.Nat64;
  const TransferError = IDL.Variant({
    'TxTooOld' : IDL.Record({ 'allowed_window_nanos' : IDL.Nat64 }),
    'BadFee' : IDL.Record({ 'expected_fee' : Tokens }),
    'TxDuplicate' : IDL.Record({ 'duplicate_of' : BlockIndex }),
    'TxCreatedInFuture' : IDL.Null,
    'InsufficientFunds' : IDL.Record({ 'balance' : Tokens }),
  });
  const TransferResult = IDL.Variant({
    'Ok' : BlockIndex,
    'Err' : TransferError,
  });
  const MockNFT = IDL.Service({
    'addAdmin' : IDL.Func([IDL.Principal], [], ['oneway']),
    'balance' : IDL.Func([], [IDL.Vec(IDL.Nat)], ['query']),
    'getAdmins' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'getPersonalAccount' : IDL.Func([], [AccountIdentifier], []),
    'launchpadEventCreate' : IDL.Func([Data], [IDL.Nat], []),
    'launchpadEventUpdate' : IDL.Func([IDL.Nat, Data], [Result__1], []),
    'launchpadMint' : IDL.Func([IDL.Principal], [Result], []),
    'launchpadTotalAvailable' : IDL.Func([IDL.Nat], [IDL.Nat], ['query']),
    'reset' : IDL.Func([IDL.Nat], [], ['oneway']),
    'toggleTrap' : IDL.Func([IDL.Bool], [], ['oneway']),
    'transfer' : IDL.Func([AccountIdentifier], [TransferResult], []),
  });
  return MockNFT;
};
