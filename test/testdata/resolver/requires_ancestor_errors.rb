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

module E
  extend T::Helpers
  requires_ancestor A
  requires_ancestor A # error: `A` is already required by `E`
end

module F
  extend T::Helpers
  requires_ancestor A # error: `A` is already included by `F`
  include A
end

class G; end

class H < G
  extend T::Helpers
  requires_ancestor G # error: `G` is already inherited by `H`
end

class I < H
  extend T::Helpers
  requires_ancestor G # error: `G` is already inherited by `I`
end
