class Blocker_process

  def initialize (log,pidf)
    @pid = $$
		@log = log
		@pidf = pidf
		if FileTest.exist?(@pidf)
			`kill -0 $(cat #{@pidf}` #` 2>/dev/null) 2>/dev/null")`
			if $? == 0
	                        @log.error 'Blocker daemon seems already running.'
                	        @log.close
				exit 1
			else
				File.open(@pidf, "w") {|f| f.puts(@pid)}
			end
		else
			File.open(@pidf, "w") {|f| f.puts(@pid)}
		end
  end

  def shutdown
		if not $db.nil?
			if $db.running?
				$db.stop_db
			end
		end
		@log.append("Stopping blocker daemon: pid #{@pid}...")
		@log.close
		pid_remove
		exit 1
  end

	def critical_error
    @log.append("Stopping blocker daemon: pid #{@pid}...")
		pid_remove
    exit 100
  end

	private

	def pid_remove
		File.unlink(@pidf)
	end

end
