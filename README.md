# yard-sorbet
[![Gem Version](https://badge.fury.io/rb/yard-sorbet.svg)](https://badge.fury.io/rb/yard-sorbet)
[![Build Status](https://github.com/dduugg/yard-sorbet/actions/workflows/ruby.yml/badge.svg)](https://github.com/dduugg/yard-sorbet/actions/workflows/ruby.yml)
[![codecov](https://codecov.io/gh/dduugg/yard-sorbet/branch/master/graph/badge.svg)](https://codecov.io/gh/dduugg/yard-sorbet)

A YARD [plugin](https://rubydoc.info/gems/yard/file/docs/GettingStarted.md#plugin-support) that parses Sorbet type annotations

## Features
- Attaches existing documentation to methods and attributes that follow `sig` declarations. (This information is otherwise discarded.)
- Translates `sig` type signatures into corresponding YARD tags
- Generates method definitions from `T::Struct` fields
- Generates constant definitions from `T::Enum` enums
- Modules marked `abstract!` or `interface!` are tagged `@abstract`
- Modules using `mixes_in_class_methods` will attach class methods
- Merges `sig`s in rbi files with source code documentation (rbi files must come after source code in yard configuration)

## Usage

See the Plugin Support [section](https://rubydoc.info/gems/yard/file/docs/GettingStarted.md#plugin-support) of the YARD docs.

## Used By

This plugin is used by:
- The [Homebrew Ruby API](https://rubydoc.brew.sh/index.html)
- [Tapioca](https://github.com/Shopify/tapioca), to optionally include YARD documentation from sources when generating RBIs
- `yard-sorbet` [itself](https://dduugg.github.io/yard-sorbet/)
