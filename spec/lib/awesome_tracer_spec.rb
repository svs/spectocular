require 'simplecov'
SimpleCov.start
require 'awesome_tracer'
require 'pry-byebug'

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

describe AwesomeTracer do


  before(:each) {
    AwesomeTracer.start!({path: 'awesome_tracer/spec'})
  }
  after(:each) {
    AwesomeTracer.stop!
  }


  it "should start and stop" do
    Foo.new("foo").bar
    AwesomeTracer.should be_running
    AwesomeTracer.stop!
    AwesomeTracer.should_not be_running
  end

  describe "trace" do
    before(:each) { Foo.new("foo").bar }
    subject { AwesomeTracer }
    it "should have files" do
      expect (AwesomeTracer.files).to_eq(["/Users/svs/src/awesome_tracer/spec/lib/awesome_tracer_spec.rb"])
    end
    #its(:max_level) { should == 2 }
    #specify { subject.trace.count.should == 14 }
  end





end
