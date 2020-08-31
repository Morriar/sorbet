# typed: true

module A; end

module B
  extend T::Helpers
  requires_ancestor A
end

class C # error: `C` must include `A` (required by `B`)
  include B
end

class D < C # error: `D` must include `A` (required by `B`)
end

class E < D # error: `E` must include `A` (required by `B`)
end

module F
  include B
end

module G
  include F
end

class H
  extend T::Helpers
  include G
  abstract!
end

class I < H
  extend T::Helpers
  abstract!
end

class J < I # error: `J` must include `A` (required by `B`)
end
