require 'rspec/core/formatters/progress_formatter'
require 'net/http'
require 'faye'
require_relative './trace.rb'


class Fay3Formatter
  # Watches RSpec output and sends it as nicely formatted JSON to Faye server
  RSpec::Core::Formatters.register self, :example_group_started, :example_started, :example_passed, :example_failed, :example_pending

  def initialize output
    @output = output
  end

  @@tp_call = TracePoint.new(:call) do |tp|
    if tp.path.to_s =~ /foo/
      Trace.faye_log({class: tp.defined_class, path: tp.path, method: tp.method_id, line: tp.lineno, event: tp.event})
    end
  end
  @@tp_call.enable

  @@tp_line = TracePoint.new(:line) do |tp|
    if tp.path.to_s =~ /foo/
      Trace.faye_log({class: tp.defined_class, path: tp.path, method: tp.method_id, line: tp.lineno, event: tp.event})
    end
  end
  @@tp_line.enable



  @@tp_return = TracePoint.new(:return) do |tp|
    if tp.path.to_s =~ /foo/
      Trace.faye_log({class: tp.defined_class, path: tp.path, method: tp.method_id, line: tp.lineno, return_value: tp.return_value, event: tp.event})
    end
  end
  @@tp_return.enable


  # set_trace_func proc { |e,f,l,i,b, c|
  #   if c.to_s =~ /Foo/
  #     p [e,f,l,i,b, c]
  #     m = b.eval("method('#{i}')")
  #     s1 = m.source.split("\n")[l - m.source_location[1] - 1]
  #     s2 = m.source.split("\n")[l - m.source_location[1]]
  #     ivs = s1.scan(/@\w*/) + s2.scan(/@\w*/)
  #     unless ivs.empty?
  #       ivars = Hash[ivs.map{|iv| ["#{f}:#{l}:#{i}:#{iv}",b.eval(iv.to_s)]}]
  #     end
  #     b.eval("Trace.push('#{f}', '#{i}', '#{l}', '#{ivars}')")
  #   end
  # }

  def example_group_started(n)
    eg = n.group
    publish('/example_group_started', {event: "example_group_started", name: eg.description, parents: eg.parent_groups.reverse[0..-2].map(&:description), file_path: eg.file_path})
  end


  def example_started(n)
    ap 'example_started'
    e = n.example
    Trace.set_location(e.location)
  end

  def example_passed(n)
    example = n.example
    publish('/example_finished', as_json(example).merge("event" => "example_passed"))
  end

  def example_failed(n)
    example = n.example
    publish('/example_finished', as_json(example).merge("event" => "example_failed"))
  end


  private

  def publish(channel, message, transport = 'http')
    ap "publishing to #{channel} via #{transport}"
    if transport == 'http'
      message = {:channel => channel, :data => message}
      uri = URI.parse("http://localhost:9292/faye")
      Net::HTTP.post_form(uri, :message => message.to_json)
    else
      EM.run do
        c = Faye::Client.new('http://localhost:9292/faye')
        pbl = c.publish(channel, message)
        pry.byebug
        p.callback { EM.stop_event_loop }
        p.errback {|error| ap error}
      end
    end
  end


  def as_json(example)
    {
      location: example.location,
      file_path: File.expand_path(example.file_path),
      description: example.full_description,
      parents: example.example_group.parent_groups.reverse.map(&:description),
      exception: example.exception,
      execution_result: example.execution_result,
      status: example.metadata[:execution_result].status,
      trace: Trace.traces(example.location),
      files: Trace.files(example.location),
      example_group: example.example_group.display
    }

  end
end
