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
export type MintError = { 'NoneAvailable' : null } |
  { 'TryCatchTrap' : null };
export interface MockNFT {
  'launchpadEventCreate' : (arg_0: Data) => Promise<bigint>,
  'launchpadEventUpdate' : (arg_0: bigint, arg_1: Data) => Promise<undefined>,
  'launchpadMint' : (arg_0: Principal) => Promise<Result>,
  'launchpadTotalAvailable' : (arg_0: bigint) => Promise<bigint>,
  'withdrawAll' : (arg_0: AccountIdentifier) => Promise<TransferResult>,
}
export type Result = { 'ok' : bigint } |
  { 'err' : MintError };
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
export interface _SERVICE extends MockNFT {}
