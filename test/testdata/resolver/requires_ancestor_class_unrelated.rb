# typed: true

class C0; end
class C1; end
class C2; end
class C3 < C2; end
class C4 < C3; end
class C5 < C4; end

  module A
# ^^^^^^^^ error: `A` requires unrelated classes `C1` and `C2` making it impossible to include
    extend T::Helpers
    requires_ancestor C1, C2
  end

module B
  extend T::Helpers
  requires_ancestor C2, C3
end

module C
  extend T::Helpers
  requires_ancestor C2, C4
end

module D
  extend T::Helpers
  requires_ancestor C2, C5
end

  module E
# ^^^^^^^^ error: `E` requires unrelated classes `C0` and `C1` making it impossible to include
# ^^^^^^^^ error: `E` requires unrelated classes `C0` and `C2` making it impossible to include
# ^^^^^^^^ error: `E` requires unrelated classes `C1` and `C2` making it impossible to include
    extend T::Helpers
    requires_ancestor C0, C1, C2
  end

  class CC1 < C1
# ^^^^^^^^^^^^^^ error: `CC1` must subclass `C2` (required by `A`)
# ^^^^^^^^^^^^^^ error: `CC1` requires unrelated classes `C1` and `C2` making it impossible to include
    include A
  end

  class CC2 < C2 # error: `CC2` must subclass `C3` (required by `B`)
    include B
  end

  class CC3 < C3
    include B
  end

  class CC4 < C4
    include C
  end

  class CC5 < C5
    include D
  end
