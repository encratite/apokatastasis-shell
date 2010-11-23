require 'thread'

class ShellClient
	ReadSize = 2**10

	def initialize(socket)
		Thread.abort_on_exception = true
		@socket = socket
		Thread.new do
			handleClient
		end
	end

	def performIO(&block)
		begin
			return block.call
		rescue IOError
			return nil
		end
	end

	def print(line)
		protocol, port, address = @socket.peeraddr
		puts "[#{address}:#{port}] #{line}"
	end

	def handleClient
		print 'Client connected'
		while true
			data = performIO do
				@socket.readpartial(ReadSize)
			end
			if data == nil
				print 'Client disconnected'
				return
			end
			print "Data: #{data.inspect}"
		end
	end
end
