# Progenitus

> : descended.

## Tests

### TypeScript

```sh
cp .env.example .env
npm i
npm run makeadmin
npm run test:dfx
```

### Motoko

```sh
./.scripts/moc-test
```

## Project Structure

```text
./
├── keys  | Private test keys used in the test suite.
├── lib   | TS testing library.
├── src   | The Motoko source code.
└── tests | Both TS and Motoko tests.
```

## Utility Scripts

```shell
export PATH=$PATH:$(pwd)/.scripts

# moc-check src/main.mo
```

## Resources

- [Ledger Canister](https://github.com/dfinity/ic/tree/master/rs/rosetta-api/ledger_canister)
