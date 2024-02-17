# typed: strict
# frozen_string_literal: true

# This may include Gem::RequestSet::GemDependencyAPI methods from
# https://github.com/sorbet/sorbet/blob/master/rbi/stdlib/rubygems.rbi

# Loads dependencies from a gemspec file.
#
# `options` include:
#
# name:
# :   The name portion of the gemspec file. Defaults to searching for any
#     gemspec file in the current directory.
#
# ```ruby
# gemspec name: 'my_gem'
# ```
#
# path:
# :   The path the gemspec lives in. Defaults to the current directory:
#
# ```ruby
# gemspec 'my_gem', path: 'gemspecs', name: 'my_gem'
# ```
#
# development\_group:
# :   The group to add development dependencies to. By default this is
#     :development. Only one group may be specified.
def gemspec(options = T.unsafe(nil)); end

# Sets `url` as a source for gems for this dependency API. RubyGems uses the
# default configured sources if no source was given. If a source is set only
# that source is used.
#
# This method differs in behavior from Bundler:
#
# *   The `:gemcutter`, # `:rubygems` and `:rubyforge` sources are not
#     supported as they are deprecated in bundler.
# *   The `prepend:` option is not supported. If you wish to order sources
#     then list them in your preferred order.
def source(url); end
