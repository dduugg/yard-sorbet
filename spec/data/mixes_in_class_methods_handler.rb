# typed: true
module M
  extend T::Helpers
  interface!

  module ClassMethods
    extend T::Sig
    extend T::Helpers
    abstract!

    sig {void}
    def foo
      bar
    end

    sig {abstract.void}
    def bar; end
  end

  mixes_in_class_methods(ClassMethods)
end

class A # error: Missing definition for abstract method
  include M

  extend T::Sig

  sig {override.void}
  def self.bar; end
end

# Sorbet knows that `foo` is a class method on `A`
A.foo

module Receiver; end

Receiver.include(M)

module OuterModule
  module InnerModule
    extend T::Helpers
    module ClassMethods
      def foo; end
    end
    mixes_in_class_methods(ClassMethods)
  end

  class InnerClass
    include InnerModule
  end
end

module M2; end
module M3; end

class C
  extend T::Sig

  include M2, M, M3

  sig {override.void}
  def self.bar; end
end
