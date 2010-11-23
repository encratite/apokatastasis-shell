require 'socket'

require_relative 'ShellClient'

class ShellServer
	def initialize(port)
		@server = TCPServer.new('127.0.0.1', port)
	end

	def run
		while true
			client = ShellClient.new(@server.accept)
		end
	end
end
