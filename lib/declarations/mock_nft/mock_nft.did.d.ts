import type { Principal } from '@dfinity/principal';
export type Access = { 'Private' : Allowlist } |
  { 'Holders' : HolderAccess } |
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
  { 'IndexNotFound' : bigint } |
  { 'AlreadyOver' : Time } |
  { 'NotStarted' : Time };
export type EventName = string;
export interface HolderAccess {
  'canisters' : Array<Principal>,
  'allowType' : HolderAllowType,
}
export type HolderAllowType = { 'Unlimited' : null };
export type MintError = { 'NoneAvailable' : null } |
  { 'TryCatchTrap' : string };
export interface MockNFT {
  'addAdmin' : (arg_0: Principal) => Promise<undefined>,
  'balance' : () => Promise<Array<bigint>>,
  'getAdmins' : () => Promise<Array<Principal>>,
  'getPersonalAccount' : () => Promise<AccountIdentifier>,
  'launchpadBalanceOf' : (arg_0: Principal) => Promise<bigint>,
  'launchpadEventCreate' : (arg_0: Data) => Promise<bigint>,
  'launchpadEventUpdate' : (arg_0: bigint, arg_1: Data) => Promise<Result__1>,
  'launchpadMint' : (arg_0: Principal) => Promise<Result>,
  'launchpadTotalAvailable' : (arg_0: bigint) => Promise<bigint>,
  'launchpadTotalSupply' : (arg_0: bigint) => Promise<bigint>,
  'reset' : (arg_0: bigint) => Promise<undefined>,
  'toggleTrap' : (arg_0: boolean) => Promise<undefined>,
  'transfer' : (arg_0: AccountIdentifier) => Promise<TransferResult>,
}
export type Result = { 'ok' : bigint } |
  { 'err' : MintError };
export type Result__1 = { 'ok' : null } |
  { 'err' : Error };
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
export interface _SERVICE extends MockNFT {}
