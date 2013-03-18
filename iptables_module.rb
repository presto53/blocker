require 'posix/spawn'

module Iptables_module

  def add_rule(source, chain)
    run_cmd("#{@bin} -A #{chain} -s #{source} -j DROP")
  end

  def del_rule(source, chain)
    run_cmd("#{@bin} -D #{chain} -s #{source} -j DROP")
  end

  def rule_exist?(source, chain)
    if POSIX::Spawn::Child.new("#{@bin} -D #{chain} -s #{source} -j DROP").success?
       POSIX::Spawn::Child.new("#{@bin} -A #{chain} -s #{source} -j DROP")
       true
    else
      false
    end
  end

  def list(chain)
    result = POSIX::Spawn::Child.new("#{@bin} -L #{chain} -n")
    if result.success?
      ip_list = []
      result.out.split(/\n/).each do |line|
	if line.match('^DROP')
	  line.split(/\s/).each do |ip|
	    if !(IPAddr.new(ip) rescue nil).nil?
	      ip_list << ip if not ip.match('/')
	    end
	  end
	end
      end
    else
      raise "cannot add chain #{chain}" 
    end
    ip_list
  end

  # Add main rule in INPUT chain and create new chain for rules
  def add_chain(chain,protocol,ports)
    # If chain does not exist, try to add new chain
    if not POSIX::Spawn::Child .new("#{@bin} -L #{chain}").success?
      raise "cannot add chain #{chain}" if not POSIX::Spawn::Child.new("#{@bin} -N #{chain}").success?
    end
    # If main rule does not exist, try to add new rule
    POSIX::Spawn::Child.new("#{@bin} -D INPUT -p #{protocol} -m multiport --dports #{ports.join(',')} -j #{chain}")
    raise "cannot add rule" if not POSIX::Spawn::Child.new("#{@bin} -I INPUT 1 -p #{protocol} -m multiport --dports #{ports.join(',')} -j #{chain}").success?
    true
  end

  def remove_chain(chain,protocol,ports)
    # Flush chain if it exist
     if POSIX::Spawn::Child.new("#{@bin} -L #{chain}").success?
       raise "cannot flush chain #{chain}" if not POSIX::Spawn::Child.new("#{@bin} -F #{chain}").success?
      # Delete main rule if it exist
      POSIX::Spawn::Child.new("#{@bin} -D INPUT -p #{protocol} -m multiport --dports #{ports.join(',')} -j #{chain}")
      # Delete chain
      raise "cannot delete chain #{chain}" if not POSIX::Spawn::Child.new("#{@bin} -X #{chain}").success?
    end 
  end

  private

  # Asynchronous run command
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
