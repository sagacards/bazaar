import type { Principal } from '@dfinity/principal';
export type Access = { 'Private' : Allowlist } |
  { 'Public' : null };
export type AccountIdentifier = Array<number>;
export type Allowlist = Array<[Principal, Spots]>;
export type BlockIndex = bigint;
export interface CollectionDetails {
  'descriptionMarkdownUrl' : URL,
  'iconImageUrl' : URL,
  'bannerImageUrl' : URL,
  'previewImageUrl' : URL,
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
export type Error = { 'NotInAllowlist' : null } |
  { 'TokenNotFound' : Principal } |
  { 'IndexNotFound' : bigint };
export type Event = [Principal, Data, bigint];
export type EventName = string;
export type Events = Array<Event>;
export type MintError = { 'NoneAvailable' : null } |
  { 'Refunded' : null } |
  { 'TryCatchTrap' : null } |
  { 'NoMintingSpot' : null } |
  { 'Transfer' : TransferError } |
  { 'Events' : Error };
export type MintResult = { 'ok' : bigint } |
  { 'err' : MintError };
export type Result = { 'ok' : null } |
  { 'err' : Error };
export type Result_1 = { 'ok' : Data } |
  { 'err' : Error };
export type Result__1 = { 'ok' : bigint } |
  { 'err' : Error };
export interface Rex {
  'addAdmin' : (arg_0: Principal) => Promise<undefined>,
  'balance' : () => Promise<Tokens>,
  'createEvent' : (arg_0: Data) => Promise<bigint>,
  'currentlyMinting' : () => Promise<bigint>,
  'getAdmins' : () => Promise<Array<Principal>>,
  'getAllEvents' : () => Promise<Events>,
  'getAllowlistSpots' : (arg_0: Principal, arg_1: bigint) => Promise<Result__1>,
  'getEvent' : (arg_0: Principal, arg_1: bigint) => Promise<Result_1>,
  'getEvents' : (arg_0: Array<Principal>) => Promise<Events>,
  'getEventsOfToken' : (arg_0: Principal) => Promise<Array<Data>>,
  'getOwnEvents' : () => Promise<Array<Data>>,
  'getPersonalAccount' : () => Promise<AccountIdentifier>,
  'mint' : (arg_0: Principal, arg_1: bigint) => Promise<MintResult>,
  'removeAdmin' : (arg_0: Principal) => Promise<undefined>,
  'removeEvent' : (arg_0: Principal, arg_1: bigint) => Promise<undefined>,
  'transfer' : (arg_0: Tokens, arg_1: AccountIdentifier) => Promise<
      TransferResult
    >,
  'updateEvent' : (arg_0: bigint, arg_1: Data) => Promise<Result>,
}
export type Spots = [] | [bigint];
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
export type URL = string;
export interface _SERVICE extends Rex {}
