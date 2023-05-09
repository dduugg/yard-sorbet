# Changelog

## main

### Bug Fixes

* Fix syntax of order-dependent lists

## 0.8.1 (2023-04-03)

### Bug Fixes

* [#201](https://github.com/dduugg/yard-sorbet/issues/201) Caching not reloading docstring when using Sorbet signature

## 0.8.0 (2023-01-14)

### New Features

* [#141](https://github.com/dduugg/yard-sorbet/issues/141) Merge RBI sigs into existing documentation

### Bug Fixes

* Handle multiple invocations of `mixes_in_class_methods` within a class
* Label `T::Struct` `prop`s with `immutable: true` as `readonly`

## 0.7.0 (2022-08-24)

### Bug Fixes

* [#98](https://github.com/dduugg/yard-sorbet/pull/98) Fix typo in abstract tag text

### Changes

* Increase minimum required ruby version to `2.7.0`

## 0.6.1 (2021-11-01)

### Bug fixes

* [#78](https://github.com/dduugg/yard-sorbet/pull/78) Fix `mixes_in_class_methods` across files

## 0.6.0 (2021-10-13)

### New features

* [#77](https://github.com/dduugg/yard-sorbet/pull/77) Add `mixes_in_class_methods` support

## 0.5.3 (2021-08-01)

### Bug fixes

* [#71](https://github.com/dduugg/yard-sorbet/pull/71) Fix `T::Struct` constructor object creation

## 0.5.2 (2021-07-01)

### Bug fixes

* [#61](https://github.com/dduugg/yard-sorbet/pull/61) Fix parsing of `sig` with nested return types
* [#63](https://github.com/dduugg/yard-sorbet/pull/63) Fix parsing of `top_const_ref` nodes (e.g. `::Foo`)
* [#64](https://github.com/dduugg/yard-sorbet/pull/64) Fix parsing of `list` nodes
* [#65](https://github.com/dduugg/yard-sorbet/pull/65) Fix parsing of nested `array` nodes

## 0.5.1 (2021-06-08)

### Bug fixes

* [#52](https://github.com/dduugg/yard-sorbet/issues/52) Fix `sig` parsing of attr_* methods that use parens

## 0.5.0 (2021-05-28)

### New features

* [#49](https://github.com/dduugg/yard-sorbet/issues/49) Apply `@abstract` tags to `abstact!`/`interface!` modules
* [#43](https://github.com/dduugg/yard-sorbet/issues/43) Add `T::Enum` support

### Bug fixes

* [#41](https://github.com/dduugg/yard-sorbet/issues/41) Fix superfluous return type of boolean methods with inline modifiers

### Changes

* Increase minimum `sorbet` version to `0.5.6289`
* Increase minimum `yard` version to `0.9.21`

## 0.4.1 (2021-04-28)

### Bug fixes

* [#32](https://github.com/dduugg/yard-sorbet/issues/32) Fix processing of `T::Struct` field names that are ruby keywords or capitalized

## 0.4.0 (2021-04-02)

### New features

* [#15](https://github.com/dduugg/yard-sorbet/issues/15) Add support for `T::Struct` `prop` declarations

## 0.3.0 (2021-03-11)

### New features

* Add `YARDSorbet::VERSION`

### Bug fixes

* [#26](https://github.com/dduugg/yard-sorbet/pull/26): Remove sorbet `default_checked_level`

## 0.2.0 (2021-01-14)

### Bug fixes

* [#17](https://github.com/dduugg/yard-sorbet/pull/17): Fix docstrings for methods that contain a comment on method definition line

### Changes

* [#16](https://github.com/dduugg/yard-sorbet/pull/16): Enforce strict typing in non-spec code.
* Require yard >= 0.9.16 and sorbet-runtime >= 0.5.5845

## 0.1.0 (2020-12-01)

### New features

* [#8](https://github.com/dduugg/yard-sorbet/pull/8): Add support for singleton class syntax.
* [#7](https://github.com/dduugg/yard-sorbet/pull/7): Add support for top-level constants in sigs.

### Bug fixes

* [#9](https://github.com/dduugg/yard-sorbet/pull/9): Remove warning for use of `T.attached_class`.
* [#11](https://github.com/dduugg/yard-sorbet/pull/11): Fix parsing of custom parameterized types.
* [#12](https://github.com/dduugg/yard-sorbet/pull/12): Fix parsing of recursive custom parameterized types.

### Changes

* [#10](https://github.com/dduugg/yard-sorbet/pull/10): Downgrade log level of unsupported `sig` `aref` nodes.
* Drop Ruby 2.4 support

## 0.0.1 (2020-01-24)

### New Features

* [#1](https://github.com/dduugg/yard-sorbet/pull/1): Add `T::Struct` support.

### Changes

* [#3](https://github.com/dduugg/yard-sorbet/pull/3): Rename require path to be conistent with gem name.

## 0.0.0 (2020-01-05)

* Initial Release
