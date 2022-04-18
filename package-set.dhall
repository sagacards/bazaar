let upstream = https://github.com/aviate-labs/package-set/releases/download/v0.1.5/package-set.dhall sha256:8cfc64fd3c6e8aa93390819b5f96dfb064afb63817971bcc8d9aa00c312ec8ab

let additions = [
    { name = "canistergeek"
    , repo = "https://github.com/usergeek/canistergeek-ic-motoko"
    , version = "v0.0.3"
    , dependencies = ["base"] : List Text
    }
]

in  upstream # additions
