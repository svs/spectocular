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
