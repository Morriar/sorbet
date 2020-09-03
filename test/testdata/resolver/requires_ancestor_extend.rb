# typed: true

module Helpers
  def help; end
end

module Foo
  extend T::Helpers
  requires_ancestor Kernel, Helpers

  def foo
    help
    raise "ERROR"
  end
end

module Bar # error: `T.class_of(Bar)` must include `Helpers` (required by `Foo`)
  extend Foo

  foo
end
