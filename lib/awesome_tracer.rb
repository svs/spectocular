require "awesome_print"
require_relative './awesome_tracer/faye_formatter.rb'
require "awesome_tracer/version"

class AwesomeTracer


  def self.start!(options = {})
    @@trace = []
    @@tp = nil
    @@level = 0
    @@files = Set.new
    @@max_level = 0
    @@tp = TracePoint.new do |tp|
      if [:call, :return, :line].include?(tp.event) &&
          Array(options[:path]).map {|p| tp.path =~ /#{Regexp.escape(p)}/}.any? &&
          !(tp.path =~ /html\.erb$/)
        log = {event: tp.event, method: tp.method_id, path: tp.path, lineno: tp.lineno}
        if tp.event == :return
          log[:return_value] = tp.return_value
          log[:level] = @@level
          @@level -= 1
        elsif tp.event == :call
          log[:args] = Hash[tp.binding.eval("local_variables").map{|v| [v, tp.binding.eval(v.to_s)]}]
          @@level += 1
          @@max_level = [@@level, @@max_level].max
          log[:level] = @@level
        elsif tp.event == :line
          if tp.method_id
            b = tp.binding
            begin
              m = b.eval("method('#{tp.method_id}')") rescue nil
              if m
                src = m.source.split("\n")
                s1 = src[tp.lineno - m.source_location[1] - 1]
                s2 = src[tp.lineno - m.source_location[1]]
                ivs = s1.scan(/@\w*/) + s2.scan(/@\w*/)
                ivars = {}
                unless ivs.empty?
                  # ivars = Hash[ivs.map{|iv| p iv; ["#{tp.path}:#{tp.lineno}:#{tp.method_id}:#{iv}",(b.eval(iv.to_s) rescue nil)]}]
                end
                log[:ivars] = ivars
              end
            rescue
              log[:ivars] = "error"
            end
            log[:level] = @@level
          end
        end
        @@trace << log
        @@files << tp.path
      end
    end
    @@tp.enable
    @@running = true
  end

  def self.stop!
    @@tp.disable
  end

  def self.running?
    @@tp && @@tp.enabled?
  end

  def self.trace
    @@trace
  end

  def self.files
    @@files.to_a
  end

  def self.max_level
    @@max_level
  end

end
