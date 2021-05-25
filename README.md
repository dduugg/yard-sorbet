# yard-sorbet
[![Gem Version](https://badge.fury.io/rb/yard-sorbet.svg)](https://badge.fury.io/rb/yard-sorbet)
[![Build Status](https://travis-ci.com/dduugg/yard-sorbet.svg?branch=master)](https://travis-ci.com/dduugg/yard-sorbet)
[![codecov](https://codecov.io/gh/dduugg/yard-sorbet/branch/master/graph/badge.svg)](https://codecov.io/gh/dduugg/yard-sorbet)

A YARD [plugin](https://rubydoc.info/gems/yard/file/docs/GettingStarted.md#Plugin_Support) that parses Sorbet type annotations

## Features
- Attaches existing documentation to methods and attributs that follow `sig` declarations. (This information is otherwise discarded.)
- Translates `sig` type signatures into corresponding YARD tags
- Generates method definitions from `T::Struct` fields
- Generates constant definitions from `T::Enum` enums

## Install

```shell
gem install yard-sorbet
```

## Usage
```bash
yard doc --plugin sorbet
```
