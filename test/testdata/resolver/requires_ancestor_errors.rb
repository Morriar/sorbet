# typed: true

module A; end

module B
  requires_ancestor A # error: Method `requires_ancestor` does not exist on `T.class_of(B)`
end

module C
  extend T::Helpers
  requires_ancestor # error: `requires_ancestor` requires at least one argument
end

module D
  extend T::Helpers
  requires_ancestor "A" # error: `requires_ancestor` must only contain constant literals
end

class C1; end
class C2; end

module E # error: `E` requires `2` unrelated classes making it impossible to include
  extend T::Helpers
  requires_ancestor C1, C2
end

class F < C1 # error: `F` must subclass `C2` (required by `E`)
  include E
end
