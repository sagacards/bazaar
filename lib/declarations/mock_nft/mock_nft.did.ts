import { IDL } from "@dfinity/candid";
export const idlFactory : IDL.InterfaceFactory = ({ IDL }) => {
  const Time = IDL.Int;
  const EventName = IDL.Text;
  const StableAllowlist = IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Opt(IDL.Int)));
  const Access = IDL.Variant({
    'Private' : StableAllowlist,
    'Public' : IDL.Null,
  });
  const CollectionDetails = IDL.Record({
    'descriptionMarkdownUrl' : IDL.Text,
    'iconImageUrl' : IDL.Text,
    'bannerImageUrl' : IDL.Text,
    'previewImageUrl' : IDL.Text,
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
  const MintError = IDL.Variant({
    'NoneAvailable' : IDL.Null,
    'TryCatchTrap' : IDL.Null,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Nat, 'err' : MintError });
  const AccountIdentifier = IDL.Vec(IDL.Nat8);
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
    'launchpadEventCreate' : IDL.Func([Data], [IDL.Nat], []),
    'launchpadEventUpdate' : IDL.Func([IDL.Nat, Data], [], []),
    'launchpadMint' : IDL.Func([IDL.Principal], [Result], []),
    'launchpadTotalAvailable' : IDL.Func([IDL.Nat], [IDL.Nat], ['query']),
    'withdrawAll' : IDL.Func([AccountIdentifier], [TransferResult], []),
  });
  return MockNFT;
};
