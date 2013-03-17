require 'rubygems'
require 'rake'

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
      args = "-host #{@options['host']} -port #{@options['port']} -tout 10 -ls -dmn -pid #{@options['pid']} -log #{@options['log']} -th 8 *#bnum=8000#msiz=64m"
      cmd = "#{@options['bin']} #{args}"
      sh cmd do |ok, res|
        if not ok
          @running = false
          $log.error 'DB server start fail.'
          @blocker.shutdown
        else
          @running = true
        end
      end
    else
      $log.error 'No port option in config or port is invalid. Port must be between 1024 and 65535.'
      @blocker.shutdown
    end
  end

  def stop_db
    if FileTest.exist?(@options['pid'])
      $log.append 'Send TERM signal to DB process.'
      pid =  File.read(@options['pid']).to_i
      alive = Process.kill('TERM', pid) rescue nil
      if alive
        success = false
        10.times do
          alive = Process.kill(0, pid) rescue nil
          success = true if alive.nil?
          break if success == true
          $log.append 'Wait for DB process exit...'
          sleep 1
        end
        if success == true
          $log.append 'DB process exit successfully...'
          @running = false
        else
          $log.warning 'DB process could not shutdown. Please check logs...'
          @running = true
        end
      else
        $log.warning 'DB process not running.'
      end
    else
      $log.error "DB pid file does not exist. No #{@options['pid']}"
    end

  end

  def running?
    @running
  end

end
