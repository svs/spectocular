class Foo

  def initialize(a)
    @a = a
  end

  attr_reader :a

  def bar
    Baz.new.quux(a)
  end
end

class Baz

  def quux(a)
    a.to_s.reverse
  end

end
