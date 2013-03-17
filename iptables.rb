require 'rubygems'
require 'posix/spawn'
require 'iptables_module'

class Iptables

  attr_reader :thread

  def initialize
    @results = []
    @bin = `which iptables`.chomp rescue ''

    raise 'iptables must be run as root' if Process.uid != 0
    raise 'which or iptables commands not found' if @bin == ''

    @version = POSIX::Spawn::Child.new("#{@bin} --version").out.match('[1-9]\.[0-9]{1,}\.[0-9]{1,}')[0].split('.').join.to_i

    # Start thread for monitoring results of
    # asynchronous add and del rule commands
    @thread = Thread.new do
      loop do
        result = @results.pop()
        if result == :unsuccess
           self.exit
        end
        if result == nil
          sleep 1
        end
      end
    end
  end

  include Iptables_module

end

class Ip6tables

  attr_reader :thread

  def initialize
    @results = [] 
    raise 'system has no ipv6 support' if not File.exist?('/proc/net/if_inet6')
    @bin = `which ip6tables`.chomp rescue ''

    raise 'iptables must be run as root' if Process.uid != 0
    raise 'which or iptables commands not found' if @bin == ''

    @version = POSIX::Spawn::Child.new("#{@bin} --version").out.match('[1-9]\.[0-9]{1,}\.[0-9]{1,}')[0].split('.').join.to_i

    # Start thread for monitoring results of
    # asynchronous add and del rule commands
    @thread = Thread.new do
      loop do
        result = @results.pop()
        if result == :unsuccess
           self.exit
        end
        if result == nil
          sleep 1
        end
      end
    end
  end

  include Iptables_module

end
