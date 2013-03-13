require 'rubygems'
require 'posix/spawn'

class Blocker_DB

	def initialize (options, blocker)
		@blocker = blocker
		@options = options
		@running = false
		if FileTest.exist?(@options['pid'])
      pid =  File.read(@options['pid']).to_i
			alive = Process.kill(0, pid) rescue nil
			if alive
	      $log.error 'DB daemon seems already running.'
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
      args = "-port #{@options['port']} -tout 10 -ls -dmn -pid #{@options['pid']} -log #{@options['log']} -th 8 *#bnum=8000#msiz=64m"
      cmd = "#{@options['bin']} #{args}"
      $threads << Thread.new do
        $log.append 'Create db thread...'
        @running = true
        if POSIX::Spawn::Child.new(cmd).success?
          @running = false
          $log.warning 'DB server was shutdown.'
        else
          @running = false
          $log.error 'DB server start fail.'
          @blocker.shutdown
        end
      end
      # Wait while db server starting
      sleep 3
    else
      $log.error 'No port option in config or port is invalid. Port must be between 1024 and 65535.'
      @blocker.shutdown
    end
	end

	def stop_db
		if FileTest.exist?(@options['pid'])
      success = false
			$log.append 'Send TERM signal to DB process.'
			pid =  File.read(@options['pid']).to_i
      alive = Process.kill('TERM', pid) rescue nil
      if alive
        until success do
          $log.append 'Wait for DB process exit...'
          alive = Process.kill(0, pid) rescue nil
          success = true if alive.nil?
          sleep 1
        end
        $log.append 'DB process exit successfully...'
        @running = false
      else
        $log.append 'DB process seem not running...'
      end
    else
      $log.error "DB pid file does not exist. No #{@options['pid']}"
    end

	end

	def running?
		@running
	end

end
