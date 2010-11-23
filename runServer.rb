require_relative 'ShellServer'

if ARGV.size != 1
	puts '<port>'
	exit
end

port = ARGV.first.to_i
server = ShellServer.new(port)
server.run
