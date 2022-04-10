# Progenitus

> : descended.

## Tests

```sh
cp .env.example .env
npm i
npm run makeadmin
npm run test:dfx
```

## Project Structure

```text
./
├── src
└── test
```

### `src`

Motoko source files.

### `test`

Motoko test files.

## Utility Scripts

```shell
export PATH=$PATH:$(pwd)/.scripts

# moc-check src/main.mo
```

## Resources

- [Ledger Canister](https://github.com/dfinity/ic/tree/master/rs/rosetta-api/ledger_canister)
