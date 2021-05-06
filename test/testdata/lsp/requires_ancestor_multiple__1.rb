# typed: true
# enable-experimental-requires-ancestor: true

module Bar
  extend T::Helpers

  mixes_in_class_methods Foo

  def bar
    foo # error: Method `foo` does not exist on `Bar`
  end

  def baz; end
end
