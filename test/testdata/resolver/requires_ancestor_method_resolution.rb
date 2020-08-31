# typed: true

module A
  def a; end
end

module B
  extend T::Helpers
  requires_ancestor A

  def b
    a
  end
end

module C
  extend T::Helpers
  requires_ancestor B

  def c
    a
    b
  end
end

module D
  extend T::Helpers
  requires_ancestor C

  def d
    a
    b
    c
  end
end

class E
  include A
  include B
  include C
  include D
end
