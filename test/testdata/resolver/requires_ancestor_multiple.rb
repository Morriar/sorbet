# typed: true

class H1; end
module H2; end
module H3; end
module H4; end

module A
  extend T::Helpers
  requires_ancestor H1, H2
end

module B
  extend T::Helpers
  requires_ancestor H3
  requires_ancestor H4
end

class C < H1
  extend T::Helpers
  include A
  include B
  abstract!
end

class D < C
  include H2, H3, H4
  include A
  include B
end

module E
  include H2
end

module F
  include H3
  include H4
end

class G < C
  include A, B, E, F
end

class E1 # error: `E1` must subclass `H1` (required by `A`)
  include A
  include B
  include H2, H3, H4
end

class E2 < H1 # error: `E2` must include `H2` (required by `A`)
  include A
  include B
  include H3, H4
end

class E3 < H1 # error: `E3` must include `H3` (required by `B`)
  include A
  include B
  include H2, H4
end

class E4 < H1 # error: `E4` must include `H4` (required by `B`)
  include A
  include B
  include H2, H3
end
