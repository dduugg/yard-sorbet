# typed: true
# frozen_string_literal: true

module YARDSorbet
  module Handlers
    # Tracks modules that invoke `mixes_in_class_methods` for use in {IncludeHandler}
    # @see https://sorbet.org/docs/abstract#interfaces-and-the-included-hook
    #   Sorbet `mixes_in_class_methods` documentation
    class MixesInClassMethodsHandler < YARD::Handlers::Ruby::Base
      handles method_call(:mixes_in_class_methods)
      namespace_only

      @@mix_in_class_methods = {} # rubocop:disable Style/ClassVars

      def self.mixed_in_class_methods(code_obj)
        @@mix_in_class_methods[code_obj]
      end

      def process
        @@mix_in_class_methods[namespace.to_s] ||= []
        @@mix_in_class_methods.fetch(namespace.to_s) << statement.parameters(false)[0].source
      end
    end
  end
end
