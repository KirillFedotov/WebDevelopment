require 'socket'

server = TCPServer.new 2000 # Server bind to port 2000
loop do
  client = server.accept    # Wait for a client to connect
  data = "<!doctype html><html><head><title>My page</title></head>" +
         "<body><h1>Hello!</h1></body></html>"
  client.puts "HTTP/1.1 200 OK"
  client.puts "Date: #{Time.now}"
  client.puts "Server: My Awesome Server"
  client.puts "X-Powered-By: Ruby/2.4.0"
  client.puts "Last-Modified: #{Time.now}"
  client.puts "Content-Language: ru"
  client.puts "Content-Type: text/html; charset=utf-8"
  client.puts "Content-Length: #{data.length}"
  client.puts "Connection: close"
  client.puts ""
  client.puts data
  client.close
end
