class Blocker_banhammer

	def initialize(target, log)
		@target = target
    @log = log
	end

	def ip_exception?(ip)
		@target['exceptions'].each do |exception_group|
			if $ip_exceptions.key?(exception_group)
        $ip_exceptions[exception_group].each do |exception|
           return true if exception.include?(IPAddr.new(ip))
        end
      else
        @log.error "no exception group #{exception_group}."
        $blocker.exit
      end
    end
    false
	end

	def ban(ip)

	end

end
