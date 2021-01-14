# Change log

## master (unreleased)

## 0.2.0 (2020-01-14)

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

* [#1](https://github.com/dduugg/yard-sorbet/pull/1): Add `T::Struct` support.
* [#3](https://github.com/dduugg/yard-sorbet/pull/3): Rename require path to be conistent with gem name.

## 0.0.0 (2020-01-05)

* Initial Release
