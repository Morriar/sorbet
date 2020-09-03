# typed: true

# Requiring itself is an error

module A # error: Circular requirement: `A` is required as an ancestor of itself
 extend T::Helpers
  requires_ancestor A
end

# A class can include a module that requires the class itself

module B
  extend T::Helpers
  requires_ancestor C

  def foo; end
end

class C
  include B

  def bar; foo; end
end

# Circular requirement is ok, we can deal with it without loops

module D
  extend T::Helpers
  requires_ancestor E

  def foo; bar; baz; end # error: Method `baz` does not exist on `D`
end

module E
  extend T::Helpers
  requires_ancestor D

  def bar; foo; baz; end # error: Method `baz` does not exist on `E`
end

class F
  include D
  include E
end

module G
  extend T::Helpers
  requires_ancestor H

  def foo; bar; baz; end # error: Method `baz` does not exist on `G`
end

module H
  extend T::Helpers
  requires_ancestor I

  def bar; foo; baz; end # error: Method `baz` does not exist on `H`
end

module I
  extend T::Helpers
  requires_ancestor G

  def bar; foo; baz; end # error: Method `baz` does not exist on `I`
end

class J
  include G
  include H
  include I
end
