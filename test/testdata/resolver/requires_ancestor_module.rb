# typed: true

module MiniTest
  module TestAssertions
    def assert_equal(x, y)
      x == y
    end
  end

  module TestCase
    include TestAssertions

    def test; end
  end
end

module MyTestHelper
  extend T::Helpers

  requires_ancestor MiniTest::TestAssertions

  def assert_not_equal(x, y)
    !assert_equal(x, y)
  end
end

class MyTest1 < MiniTest::TestCase
  include MyTestHelper
end

class MyTest2 # error: `MyTest2` must include `MiniTest::TestAssertions` (required by `MyTestHelper`)
  include MyTestHelper
end

class MyTest3
  include MiniTest::TestAssertions
  include MyTestHelper
end

class MyTest4
  extend T::Helpers
  include MyTestHelper
  abstract!
end

module MyTest5
  include MyTestHelper

  def assert_same(x, y)
    assert_equal(x, y)
  end

  def assert_not_same(x, y)
    assert_not_equal(x, y)
  end
end

class MyTest6 # error: `MyTest6` must include `MiniTest::TestAssertions` (required by `MyTestHelper`)
  include MyTest5
end
