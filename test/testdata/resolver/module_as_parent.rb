# typed: true
# disable-fast-path: true

module A
end

class B < A # error: Superclass must be a class. Module `A` given
end
