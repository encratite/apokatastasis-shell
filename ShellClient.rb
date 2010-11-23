require 'thread'

class ShellClient
	ReadSize = 2**10
	
	IAC = "\xff"
	Will = "\xfb"
	Wont = "\xfc"

	Echo = 1
	SuppressGoAhead = 3
	Linemode = 34

	def iacPacket(prefix, code)
		return IAC + prefix + code.chr
	end

	def will(code)
		return iacPacket(Will, code)
	end

	def wont(code)
		return iacPacket(Wont, code)
	end

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

	def send(data)
		performIO do
			@socket.write(data)
		end
	end

	def handleClient
		print 'Client connected'

		packet = will(Echo) + will(SuppressGoAhead) + wont(Linemode)
		send packet
		
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
