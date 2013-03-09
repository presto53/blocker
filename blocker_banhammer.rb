class Blocker_banhammer

	def initialize(target)
		@target = target
	end

	def ip_exception?(ip)
		@target['exceptions'].each do |exception_group|
			$ip_exceptions["#{exception_group}"].each do |exception|
				if ip == exception
					return true
				end
			end
		end

		return false
	end

	def ban(ip)

	end

end
