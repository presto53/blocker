class Blocker_banhammer

  def initialize(target)
    @target = target
    if @target['blockmethod'] == 'iptables'
      @method = 'i'
    else
      $log.error "unknown block method #{@target['blockmethod']}."
      $blocker.exit
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
        $blocker.exit
      end
    end
    false
  end

  def ban(ip)
    key = "#{@method}_#{ip}"
    value = $tycoon.get_value(key)
    if value.nil?
      log.warning "Can not get from db, key: #{key}."
    else
      if value == ''
        hit_counter == '1'
      else
        hit_counter = "#{value.to_i+1}"
      end
      log.warning "Can not set in db, key: #{key} value: #{hit_counter}." if $tycoon.set_value(key,hit_counter, @target['bantime']).nil?
    end
  end

end
