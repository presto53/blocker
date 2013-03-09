class Blocker_logger

        def initialize (file)
                @logf = File.open("#{file}", "a")
        end

        def append(option)
                @logf.puts "#{Time.now} [INFO] #{option}"
		@logf.fsync
        end

	def error(option)
                @logf.puts "#{Time.now} [ERROR] #{option}"
		@logf.fsync
        end

        def close
                @logf.close
        end
end
