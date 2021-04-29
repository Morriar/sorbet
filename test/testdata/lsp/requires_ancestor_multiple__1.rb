# typed: true
# enable-experimental-requires-ancestor: true

module Bar
  def bar
    foo # error: Method `foo` does not exist on `Bar`
  end
end