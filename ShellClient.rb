require 'thread'

class ShellClient
	ReadSize = 2**10
	
	Will = 251
	Wont = 252
	Do = 253
	Dont = 254
	IAC = 255

	Echo = 1
	SuppressGoAhead = 3
	Linemode = 34

	ControlSequenceSize = 3

	def initialize(socket)
		Thread.abort_on_exception = true
		@socket = socket
		Thread.new do
			handleClient
		end
		@buffer = ''
		@ignoreCounter = 0
	end

	def iacPacket(prefix, code)
		return IAC.chr + prefix.chr + code.chr
	end

	def will(code)
		return iacPacket(Will, code)
	end

	def wont(code)
		return iacPacket(Wont, code)
	end

	def do(code)
		return iacPacket(Do, code)
	end

	def dont(code)
		return iacPacket(Dont, code)
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
		print "Sending: #{data.inspect}"
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
			processNewBytes(data)
			processBuffer
		end
	end

	def processNewBytes(input)
		input.each_char do |char|
			if @ignoreCounter > 0
				@ignoreCounter -= 1
				next
			end

			case char.ord
			when 0x7f
				send "\b\x1b[K"
			when IAC
				@ignoreCounter = ControlSequenceSize - 1
			else
				send char
				@buffer << char
			end
		end
	end

	def processBuffer
		while @buffer.empty?
			offset = @buffer.index("\n")
			break if offset == nil

			line = @buffer[0..offset - 1]
			line = line.gsub("\r", '')
			processLine(line)
			@buffer = @buffer[offset + 1..-1]
		end
	end

	def processLine(line)
	end
end
