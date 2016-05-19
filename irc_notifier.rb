require 'socket'
require 'gmail' #gem install gmail

class Irc
  def initialize(server, port, nick, channel)
    @server  = server
    @port    = port
    @nick    = nick
    @channel = channel
    @socket  = nil
  end
  
  def connect()
    @socket = TCPSocket.open(@server, @port)
    @socket.puts "USER Notify 0 * Testing"
    @socket.puts "NICK #{@nick}"
    @socket.puts "JOIN #{@channel}"
  end
  
  def msg_loop()
    until @socket.eof? do
      msg = @socket.gets
      self.msg_dis(msg.downcase)
		if msg.match(/^PING :(.*)$/)
		@socket.puts "PONG #{$~[1]}"
	end
    end
  end
  
  def msg_dis(msg)
	msg.gsub!(/.*[:]/, '')
    #array = msg.split(' ')
	#puts msg
   	send_gmail() if msg =~ /name_here/  #change name_here to the nick you want to look for when sending a notification
  end
  

  def send_gmail()
	serv = @server
	chan = @channel
	#puts "Debug: send_gmail function started"
	gmail = Gmail.connect("gmail user name", "gmail password")  #replace with your gmail username and password
	gmail.deliver do
		to "phone_number" #replace phone_number with the number you want to send your notification to
		subject "IRC Notification"
		text_part do
			body "Your name was mentioned on #{serv} on channel #{chan}."
		end
	end
	gmail.logout
  end
 
  
end


irc = Irc.new("irc domain name/server", 6667, "bot name", "#channel name") #replace array with your own details
irc.connect
irc.msg_loop ##checks for messages, and sends out commands to other def's