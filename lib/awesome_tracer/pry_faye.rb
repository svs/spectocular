require 'faye'
class PryFaye < Pry::ClassCommand
  match /x(.*)/
  group 'Input and Output'
  description "All text following a 'x' is forwarded to the browser."
  command_options :listing => 'x<shell command>', :use_prefix => false,
  :takes_block => true

  banner <<-'BANNER'
      Usage: xCOMMAND

      All text following a "x" is forwarded to the browser.

      .ls -aF
      .uname
    BANNER

  def process(cmd)
    publish('/lm-ctrl', cmd)
  end

  def complete(search)
    super + Bond::Rc.files(search.split(" ").last || '')
  end

  private

    private

  def publish(channel, message)
    EM.run do
      c = Faye::Client.new('http://localhost:9292/faye')
      p = c.publish(channel, message)
      p.callback { EM.stop_event_loop }
    end
  end


end

Pry::Commands.add_command(PryFaye)
