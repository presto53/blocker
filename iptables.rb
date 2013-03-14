require 'rubygems'
require 'posix/spawn'

class Iptables

  attr_reader :thread

  def initialize(ports, chain, protocol, ip_version)
    @chain = chain
    @protocol = protocol
    @ports = ports.join(',')
    @results = []
    if ip_version == 'ipv4'
      @bin = `which iptables`.chomp rescue ''
    elsif ip_version == 'ipv6'
      raise 'system has no ipv6 support' if not File.exist?('/proc/net/if_inet6')
      @bin = `which ip6tables`.chomp rescue ''
    else
      raise 'wrong ip version. must be ipv4 or ipv6'
    end

    raise 'iptables must be run as root' if Process.uid != 0
    raise 'which or iptables commands not found' if @bin == ''

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

  def add_rule(source)
    cmd = "#{@bin} -A #{@chain} -s #{source} -j DROP"
    run_cmd(cmd)
  end

  def del_rule(source)
    cmd = "#{@bin} -D #{@chain} -s #{source} -j DROP"
    run_cmd(cmd)
  end

  def check_rule(source)
    cmd = "#{@bin} -C #{@chain} -s #{source} -j DROP"
    run_cmd(cmd)
  end

  def list
    cmd = "#{@bin} -L #{@chain} -n"
    raise "cannot add chain #{@chain}" if not POSIX::Spawn::Child.new(cmd).success?
  end

  def add_chain
    cmd = "#{@bin} -L #{@chain}"
    if not POSIX::Spawn::Child.new(cmd).success?
      cmd = "#{@bin} -N #{@chain}"
      raise "cannot add chain #{@chain}" if not POSIX::Spawn::Child.new(cmd).success?
    end
    cmd = "#{@bin} -C INPUT -p #{@protocol} -m multiport --dports #{@ports} -j #{@chain}"
    if not POSIX::Spawn::Child.new(cmd).success?
      cmd = "#{@bin} -I INPUT 1 -p #{@protocol} -m multiport --dports #{@ports} -j #{@chain}"
      raise "cannot add rule ***#{cmd}***" if not POSIX::Spawn::Child.new(cmd).success?
    end
    true
  end

  def remove_chain
    cmd = "#{@bin} -L #{@chain}"
    if POSIX::Spawn::Child.new(cmd).success?
      cmd = "#{@bin} -F #{@chain}"
      raise "cannot flush chain #{@chain}" if not POSIX::Spawn::Child.new(cmd).success?
      cmd = "#{@bin} -C INPUT -p #{@protocol} -m multiport --dports #{@ports} -j #{@chain}"
      if POSIX::Spawn::Child.new(cmd).success?
        cmd = "#{@bin} -D INPUT -p #{@protocol} -m multiport --dports #{@ports} -j #{@chain}"
        raise "cannot delete INPUT rule for chain #{@chain}" if not POSIX::Spawn::Child.new(cmd).success?
      end
      cmd = "#{@bin} -X #{@chain}"
      raise "cannot delete chain #{@chain}" if not POSIX::Spawn::Child.new(cmd).success?
    end
  end

  private

  def run_cmd(cmd)
    Thread.new do
      if POSIX::Spawn::Child.new(cmd).success?
        @results << :success
      else
        @results << :unsuccess
      end
    end
  end

end