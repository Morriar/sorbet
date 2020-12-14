# typed: true

module A
  def foo_a; end
end

module B
  extend T::Helpers

  def foo_b
    foo_a # error: Method `foo_a` does not exist on `B`
  end
end

class C
  include B
end