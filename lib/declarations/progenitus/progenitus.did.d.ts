import type { Principal } from '@dfinity/principal';
export type Access = { 'Private' : StableAllowlist } |
  { 'Public' : null };
export type AccountIdentifier = Array<number>;
export type BlockIndex = bigint;
export interface CollectionDetails {
  'descriptionMarkdownUrl' : string,
  'iconImageUrl' : string,
  'bannerImageUrl' : string,
  'previewImageUrl' : string,
}
export interface Data {
  'startsAt' : Time,
  'name' : EventName,
  'description' : string,
  'accessType' : Access,
  'details' : CollectionDetails,
  'price' : Tokens,
  'endsAt' : Time,
}
export type EventName = string;
export type Events = Array<[Principal, Data, bigint]>;
export type Result = { 'ok' : bigint } |
  { 'err' : TransferError };
export interface Rex {
  'addAdmin' : (arg_0: Principal) => Promise<undefined>,
  'balance' : () => Promise<Tokens>,
  'createEvent' : (arg_0: Data) => Promise<bigint>,
  'getAdmins' : () => Promise<Array<Principal>>,
  'getAllEvents' : () => Promise<Events>,
  'getAllowlistSpots' : (arg_0: Principal, arg_1: bigint) => Promise<
      [] | [bigint]
    >,
  'getEvent' : (arg_0: Principal, arg_1: bigint) => Promise<[] | [Data]>,
  'getEvents' : (arg_0: Array<Principal>) => Promise<Events>,
  'getEventsOfToken' : (arg_0: Principal) => Promise<Array<Data>>,
  'getOwnEvents' : () => Promise<Array<Data>>,
  'getPersonalAccount' : () => Promise<AccountIdentifier>,
  'mint' : (arg_0: Principal, arg_1: bigint) => Promise<Result>,
  'removeAdmin' : (arg_0: Principal) => Promise<undefined>,
  'transfer' : (arg_0: Tokens, arg_1: AccountIdentifier) => Promise<
      TransferResult
    >,
  'updateEvent' : (arg_0: bigint, arg_1: Data) => Promise<undefined>,
}
export type StableAllowlist = Array<[Principal, [] | [bigint]]>;
export type Time = bigint;
export interface Tokens { 'e8s' : bigint }
export type TransferError = {
    'TxTooOld' : { 'allowed_window_nanos' : bigint }
  } |
  { 'BadFee' : { 'expected_fee' : Tokens } } |
  { 'TxDuplicate' : { 'duplicate_of' : BlockIndex } } |
  { 'TxCreatedInFuture' : null } |
  { 'InsufficientFunds' : { 'balance' : Tokens } };
export type TransferResult = { 'Ok' : BlockIndex } |
  { 'Err' : TransferError };
export interface _SERVICE extends Rex {}
