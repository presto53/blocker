class Blocker_DB

	def initialize (options, log, blocker)
	
		@blocker = blocker	
		@log = log
		@options = options
		@running = false

		if FileTest.exist?(@options['pid'])
			system("kill -0 $(cat #{@options['pid']} 2>/dev/null) 2>/dev/null")
			if $? == 0
	                        @log.error 'DB daemon seems already running.'
				@blocker.shutdown
			else
				self.start_db
			end
		else
			self.start_db
		end
	end

	def start_db
		if (1024..65535) === @options['port']
			system("/usr/bin/ktserver -host #{@options['host']} -port #{@options['port']} -tout 10 -ls -dmn -pid #{@options['pid']} -log #{@options['log']} -th 8 *#bnum=8000#msiz=64m")
                        if not $? == 0
                        	@log.error 'DB server start fail.'
                        	@blocker.shutdown
			else
				@running = true
                        end
                else
                	@log.error 'No port option in config or port is invalid. Port must be between 1024 and 65535.'
                        @blocker.shutdown
                end
	end

	def stop_db
		if FileTest.exist?(@options['pid'])
			@log.append 'Send TERM signal to DB process.'
			system("kill -TERM $(cat #{@options['pid']} 2>/dev/null) 2>/dev/null")
			success = false
                        until success == true do
				system("kill -0 $(cat #{@options['pid']} 2>/dev/null) 2>/dev/null")
				if $? == 0
                                	@log.append 'Wait for DB process exit...'
					sleep 1
				else
					@log.append 'DB process exit sucessfully...'
					success = true
					@running = false
					@blocker.shutdown
				end
			end
                else
                        @log.error "DB pid file not exist. No #{@options['pid']}"
                        @blocker.shutdown
                end

	end

	def running?
		@running
	end

end
