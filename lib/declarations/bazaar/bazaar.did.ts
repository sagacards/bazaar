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
  const Error = IDL.Variant({
    'NotInAllowlist' : IDL.Null,
    'TokenNotFound' : IDL.Principal,
    'IndexNotFound' : IDL.Nat,
  });
  const Result__1_1 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : Error });
  const Event = IDL.Tuple(IDL.Principal, Data, IDL.Nat);
  const Events = IDL.Vec(Event);
  const Result__1 = IDL.Variant({ 'ok' : IDL.Int, 'err' : Error });
  const GetLogMessagesFilter = IDL.Record({
    'analyzeCount' : IDL.Nat32,
    'messageRegex' : IDL.Opt(IDL.Text),
    'messageContains' : IDL.Opt(IDL.Text),
  });
  const Nanos = IDL.Nat64;
  const GetLogMessagesParameters = IDL.Record({
    'count' : IDL.Nat32,
    'filter' : IDL.Opt(GetLogMessagesFilter),
    'fromTimeNanos' : IDL.Opt(Nanos),
  });
  const GetLatestLogMessagesParameters = IDL.Record({
    'upToTimeNanos' : IDL.Opt(Nanos),
    'count' : IDL.Nat32,
    'filter' : IDL.Opt(GetLogMessagesFilter),
  });
  const CanisterLogRequest = IDL.Variant({
    'getMessagesInfo' : IDL.Null,
    'getMessages' : GetLogMessagesParameters,
    'getLatestMessages' : GetLatestLogMessagesParameters,
  });
  const CanisterLogFeature = IDL.Variant({
    'filterMessageByContains' : IDL.Null,
    'filterMessageByRegex' : IDL.Null,
  });
  const CanisterLogMessagesInfo = IDL.Record({
    'features' : IDL.Vec(IDL.Opt(CanisterLogFeature)),
    'lastTimeNanos' : IDL.Opt(Nanos),
    'count' : IDL.Nat32,
    'firstTimeNanos' : IDL.Opt(Nanos),
  });
  const LogMessagesData = IDL.Record({
    'timeNanos' : Nanos,
    'message' : IDL.Text,
  });
  const CanisterLogMessages = IDL.Record({
    'data' : IDL.Vec(LogMessagesData),
    'lastAnalyzedMessageTimeNanos' : IDL.Opt(Nanos),
  });
  const CanisterLogResponse = IDL.Variant({
    'messagesInfo' : CanisterLogMessagesInfo,
    'messages' : CanisterLogMessages,
  });
  const MetricsGranularity = IDL.Variant({
    'hourly' : IDL.Null,
    'daily' : IDL.Null,
  });
  const GetMetricsParameters = IDL.Record({
    'dateToMillis' : IDL.Nat,
    'granularity' : MetricsGranularity,
    'dateFromMillis' : IDL.Nat,
  });
  const UpdateCallsAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterHeapMemoryAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterCyclesAggregatedData = IDL.Vec(IDL.Nat64);
  const CanisterMemoryAggregatedData = IDL.Vec(IDL.Nat64);
  const HourlyMetricsData = IDL.Record({
    'updateCalls' : UpdateCallsAggregatedData,
    'canisterHeapMemorySize' : CanisterHeapMemoryAggregatedData,
    'canisterCycles' : CanisterCyclesAggregatedData,
    'canisterMemorySize' : CanisterMemoryAggregatedData,
    'timeMillis' : IDL.Int,
  });
  const NumericEntity = IDL.Record({
    'avg' : IDL.Nat64,
    'max' : IDL.Nat64,
    'min' : IDL.Nat64,
    'first' : IDL.Nat64,
    'last' : IDL.Nat64,
  });
  const DailyMetricsData = IDL.Record({
    'updateCalls' : IDL.Nat64,
    'canisterHeapMemorySize' : NumericEntity,
    'canisterCycles' : NumericEntity,
    'canisterMemorySize' : NumericEntity,
    'timeMillis' : IDL.Int,
  });
  const CanisterMetricsData = IDL.Variant({
    'hourly' : IDL.Vec(HourlyMetricsData),
    'daily' : IDL.Vec(DailyMetricsData),
  });
  const CanisterMetrics = IDL.Record({ 'data' : CanisterMetricsData });
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
    'collectCanisterMetrics' : IDL.Func([], [], []),
    'createEvent' : IDL.Func([Data], [IDL.Nat], []),
    'currentlyMinting' : IDL.Func(
        [IDL.Principal, IDL.Nat],
        [Result__1_1],
        ['query'],
      ),
    'getAdmins' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'getAllEvents' : IDL.Func([], [Events], ['query']),
    'getAllowlistSpots' : IDL.Func(
        [IDL.Principal, IDL.Nat],
        [Result__1],
        ['query'],
      ),
    'getCanisterLog' : IDL.Func(
        [IDL.Opt(CanisterLogRequest)],
        [IDL.Opt(CanisterLogResponse)],
        ['query'],
      ),
    'getCanisterMetrics' : IDL.Func(
        [GetMetricsParameters],
        [IDL.Opt(CanisterMetrics)],
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
