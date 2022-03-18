let upstream = https://github.com/aviate-labs/package-set/releases/download/v0.1.4/package-set.dhall sha256:30b7e5372284933c7394bad62ad742fec4cb09f605ce3c178d892c25a1a9722e
let Package = { name : Text, version : Text, repo : Text, dependencies : List Text }
in  upstream # [
  { name = "dip"
  , repo = "https://github.com/aviate-labs/dip.std"
  , version = "main"
  , dependencies = [ "base" ]
  }
] : List Package
