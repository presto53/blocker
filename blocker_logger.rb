class Blocker_logger

  attr_writer :pid

  def initialize (file)
    @logf = File.open(file, 'a')
  end

  def append(option)
    @logf.puts "#{Time.now} [#{@pid}] [INFO] #{option}"
    @logf.fsync
  end

  def warning(option)
    @logf.puts "#{Time.now} [#{@pid}] [WARN] #{option}"
    @logf.fsync
  end

  def error(option)
    @logf.puts "#{Time.now} [#{@pid}] [ERROR] #{option}"
    @logf.fsync
  end

  def close
    @logf.close
  end

end
