require 'rspec/core/formatters/progress_formatter'
require 'faye'
require 'set'
class Trace

  @@traces = {}
  @@files = {}
  @@location = nil
  def self.set_location(location)
    @@location = location
  end

  def self.location
    @@location || "unknown"
  end

  # def self.push( file, method_name, line_num, ivars)
  #   @@traces[location] ||= Set.new
  #   @@traces[location] << {location: location, file: file, method_name: method_name, line_num: line_num, ivars: ivars}
  #   @@files[location] ||= Set.new
  #   @@files[location] << File.expand_path(file)
  # end

  def self.faye_log(args)
    @@traces[location] ||= Set.new([])
    @@traces[location] << args
    @@files[location] ||= Set.new([])
    @@files[location] << File.expand_path(args[:path])
  end

  def self.traces(spec_file_location = nil)
    if spec_file_location
      @@traces[spec_file_location].to_a
    end
  end

  def self.files(spec_file_location = nil)
    spec_file_location ? @@files[spec_file_location].to_a : @@files
  end



end

class FayeFormatter < RSpec::Core::Formatters::ProgressFormatter

  # Watches RSpec output and sends it as nicely formatted JSON to Faye server

  @@tp_call = TracePoint.new(:call) do |tp|
    if tp.path.to_s =~ /app/
      Trace.faye_log({class: tp.defined_class, path: tp.path, method: tp.method_id, line: tp.lineno, event: tp.event})
    end
  end
  @@tp_call.enable

  @@tp_line = TracePoint.new(:line) do |tp|
    if tp.path.to_s =~ /app/
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

  def example_group_started(eg)
    publish('/example_group_started', {event: "example_group_started", name: eg.display_name, parents: eg.parent_groups.reverse[0..-2].map(&:description), file_path: eg.file_path})
  end


  def example_started(e)
    Trace.set_location(e.location)
  end

  def example_passed(example)
    super(example)
    publish('/example_finished', as_json(example).merge("event" => "example_passed"))
  end

  def example_failed(example)
    super(example)
    publish('/example_finished', as_json(example).merge("event" => "example_failed"))
  end


  private

  def publish(channel, message)
    EM.run do
      ap [channel, message]
      c = Faye::Client.new('http://localhost:9292/faye')
      p = c.publish(channel, message)
      p.callback { EM.stop_event_loop }
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
      status: example.metadata[:execution_result][:status],
      trace: Trace.traces(example.location),
      files: Trace.files(example.location),
      example_group: example.example_group.display_name
    }

  end
end
