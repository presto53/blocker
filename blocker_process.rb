class Blocker_process

  def initialize (pidf)
    @pid = $$
    @pidf = pidf
    if FileTest.exist?(@pidf)
      pid =  File.read(@pidf).to_i
      alive = Process.kill(0, pid) rescue nil
      if alive
        $log.error 'Blocker daemon seems already running.'
        $log.close
        exit 1
      else
        File.open(@pidf, 'w') {|f| f.puts(@pid)}
      end
    else
      File.open(@pidf, 'w') {|f| f.puts(@pid)}
    end
  end

  def shutdown
    $db.stop_db if not $db.nil? and $db.running?
    $log.append("Stopping blocker daemon: pid #{@pid}...")
    $log.close
    pid_remove
    exit 1
  end

  def critical_error
    $log.append("Stopping blocker daemon: pid #{@pid}...")
    pid_remove
    exit 100
  end

  private

  def pid_remove
    File.unlink(@pidf)
  end

end
