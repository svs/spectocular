require 'simplecov'
SimpleCov.start
require 'awesome_tracer'
require_relative '../fixtures/foo.rb'
require 'pry-byebug'


describe AwesomeTracer do


  before(:each) {
    AwesomeTracer.start!({path: 'awesome_tracer/spec'})
  }
  after(:each) {
    AwesomeTracer.stop!
  }

  # it "should start and stop" do
  #     Foo.new("foo").bar
  #     AwesomeTracer.should be_running
  #     AwesomeTracer.stop!
  #     AwesomeTracer.should_not be_running
  # end

  describe "trace" do
    before(:each) { Foo.new("foo").bar }
    it "should have files" do
      pwd = Dir.pwd
      expect(AwesomeTracer.files).to eq(["#{pwd}/spec/lib/awesome_tracer_spec.rb","#{pwd}/spec/fixtures/foo.rb"])
    end
  end
end
