# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `codecov` gem.
# Please instead update this file by running `bin/tapioca gem codecov`.

# source://codecov-0.6.0/lib/codecov/version.rb:3
module Codecov
  extend ::Codecov::Configuration
end

# source://codecov-0.6.0/lib/codecov/configuration.rb:4
module Codecov::Configuration
  # Returns the value of attribute pass_ci_if_error.
  #
  # source://codecov-0.6.0/lib/codecov/configuration.rb:5
  def pass_ci_if_error; end

  # Sets the attribute pass_ci_if_error
  #
  # @param value the value to set the attribute pass_ci_if_error to.
  #
  # source://codecov-0.6.0/lib/codecov/configuration.rb:5
  def pass_ci_if_error=(_arg0); end
end

# source://codecov-0.6.0/lib/codecov/formatter.rb:8
module Codecov::SimpleCov; end

# source://codecov-0.6.0/lib/codecov/formatter.rb:9
class Codecov::SimpleCov::Formatter
  # source://codecov-0.6.0/lib/codecov/formatter.rb:12
  def format(report); end

  private

  # source://codecov-0.6.0/lib/codecov/formatter.rb:52
  def file_network; end

  # Format coverage data for a single file for the Codecov.io API.
  #
  # @param file [SimpleCov::SourceFile] The file to process.
  # @return [Array<nil, Integer>]
  #
  # source://codecov-0.6.0/lib/codecov/formatter.rb:104
  def file_to_codecov(file); end

  # Format SimpleCov coverage data for the Codecov.io API.
  #
  # @param result [SimpleCov::Result] The coverage data to process.
  # @return [Hash]
  #
  # source://codecov-0.6.0/lib/codecov/formatter.rb:39
  def result_to_codecov(result); end

  # Format SimpleCov coverage data for the Codecov.io coverage API.
  #
  # @param result [SimpleCov::Result] The coverage data to process.
  # @return [Hash<String, Array>]
  #
  # source://codecov-0.6.0/lib/codecov/formatter.rb:82
  def result_to_codecov_coverage(result); end

  # Format SimpleCov coverage data for the Codecov.io messages API.
  #
  # @param result [SimpleCov::Result] The coverage data to process.
  # @return [Hash<String, Hash>]
  #
  # source://codecov-0.6.0/lib/codecov/formatter.rb:92
  def result_to_codecov_messages(result); end

  # source://codecov-0.6.0/lib/codecov/formatter.rb:47
  def result_to_codecov_report(result); end

  # source://codecov-0.6.0/lib/codecov/formatter.rb:120
  def shortened_filename(file); end
end

# source://codecov-0.6.0/lib/codecov/formatter.rb:10
Codecov::SimpleCov::Formatter::RESULT_FILE_NAME = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:11
class Codecov::Uploader
  class << self
    # Convenience color methods
    #
    # source://codecov-0.6.0/lib/codecov/uploader.rb:557
    def black(str); end

    # source://codecov-0.6.0/lib/codecov/uploader.rb:130
    def build_params(ci); end

    # source://codecov-0.6.0/lib/codecov/uploader.rb:78
    def detect_ci; end

    # source://codecov-0.6.0/lib/codecov/uploader.rb:64
    def display_header; end

    # source://codecov-0.6.0/lib/codecov/uploader.rb:565
    def green(str); end

    # source://codecov-0.6.0/lib/codecov/uploader.rb:393
    def gzip_report(report); end

    # source://codecov-0.6.0/lib/codecov/uploader.rb:516
    def handle_report_response(report); end

    # Toggle VCR and WebMock on or off
    #
    # @param switch Toggle switch for Net Blockers.
    # @return [Boolean]
    #
    # source://codecov-0.6.0/lib/codecov/uploader.rb:530
    def net_blockers(switch); end

    # source://codecov-0.6.0/lib/codecov/uploader.rb:561
    def red(str); end

    # source://codecov-0.6.0/lib/codecov/uploader.rb:366
    def retry_request(req, https); end

    # source://codecov-0.6.0/lib/codecov/uploader.rb:36
    def upload(report, disable_net_blockers = T.unsafe(nil)); end

    # source://codecov-0.6.0/lib/codecov/uploader.rb:404
    def upload_to_codecov(ci, report); end

    # source://codecov-0.6.0/lib/codecov/uploader.rb:494
    def upload_to_v2(url, report, query, query_without_token); end

    # source://codecov-0.6.0/lib/codecov/uploader.rb:433
    def upload_to_v4(url, report, query, query_without_token); end
  end
end

# source://codecov-0.6.0/lib/codecov/uploader.rb:14
Codecov::Uploader::APPVEYOR = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:15
Codecov::Uploader::AZUREPIPELINES = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:16
Codecov::Uploader::BITBUCKET = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:17
Codecov::Uploader::BITRISE = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:18
Codecov::Uploader::BUILDKITE = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:19
Codecov::Uploader::CIRCLE = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:20
Codecov::Uploader::CIRRUS = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:21
Codecov::Uploader::CODEBUILD = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:22
Codecov::Uploader::CODESHIP = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:23
Codecov::Uploader::DRONEIO = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:24
Codecov::Uploader::GITHUB = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:25
Codecov::Uploader::GITLAB = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:26
Codecov::Uploader::HEROKU = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:27
Codecov::Uploader::JENKINS = T.let(T.unsafe(nil), String)

# CIs
#
# source://codecov-0.6.0/lib/codecov/uploader.rb:13
Codecov::Uploader::RECOGNIZED_CIS = T.let(T.unsafe(nil), Array)

# source://codecov-0.6.0/lib/codecov/uploader.rb:28
Codecov::Uploader::SEMAPHORE = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:29
Codecov::Uploader::SHIPPABLE = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:30
Codecov::Uploader::SOLANO = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:31
Codecov::Uploader::TEAMCITY = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:32
Codecov::Uploader::TRAVIS = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/uploader.rb:33
Codecov::Uploader::WERCKER = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov/version.rb:4
Codecov::VERSION = T.let(T.unsafe(nil), String)

# source://codecov-0.6.0/lib/codecov.rb:12
class SimpleCov::Formatter::Codecov
  # source://codecov-0.6.0/lib/codecov.rb:13
  def format(result, disable_net_blockers = T.unsafe(nil)); end
end