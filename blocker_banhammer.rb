class Blocker_banhammer

  def initialize(target)
    @target = target
    if not @target['blockmethod'] == 'iptables'
      $log.error "unknown block method #{@target['blockmethod']}."
      $blocker.shutdown
    end
  end

  def ip_exception?(ip)
    @target['exceptions'].each do |exception_group|
      if $ip_exceptions.key?(exception_group)
        $ip_exceptions[exception_group].each do |exception|
          return true if exception.include?(IPAddr.new(ip))
        end
      else
        $log.error "no exception group #{exception_group}."
        $blocker.shutdown
      end
    end
    false
  end

  def ban(ip)
    key = "#{@target['blockmethod']}_#{ip}"
    value = $tycoon.get_value(key)
    if value.nil?
      $log.error "Can not get from db, key: #{key}. DB server not available."
      $blocker.shutdown
    else
      if value == ''
        hit_counter = 1
      else
        hit_counter = value.to_i+1
      end
      $log.warning "Can not set in db, key: #{key} value: #{hit_counter}." if $tycoon.set_value(key,hit_counter, @target['bantime']).nil?
      if hit_counter > @target['tries']
        if @target['blockmethod'] == 'iptables'
	  $ip6tables.add_rule(ip) if IPAddr.new(ip).ipv6? and $params['ipv6'] == 'yes' 
	  $iptables.add_rule(ip) if IPAddr.new(ip).ipv4?
	end  
        $log.append "#{ip} banned."
      end
    end
  end

end
