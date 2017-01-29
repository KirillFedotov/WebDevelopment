require 'socket'

def parse_http_request(socket)
  request = {}

  # GET /favicon.ico HTTP/1.1
  line = socket.gets
  tmp = line.split(/\s+/)
  request[:method]   = tmp[0]
  request[:path]     = tmp[1]
  request[:protocol] = tmp[2]

  headers = {}
  while line = socket.gets
    line.strip!
    break if line.empty?
    # Connection: keep-alive
    tmp = line.split(':')
    headers[tmp[0].strip()] = tmp[1].strip()
  end
  request[:headers] = headers

  request
end

def handle_request(request)
  if (request[:path] == "/test-1")
    "<h1>TEST 1</h1>"
  else
    "<h1>path - #{request[:path]}</h1>"
  end
end

server = TCPServer.new 2000 # Server bind to port 2000
loop do
  client = server.accept    # Wait for a client to connect
  request = parse_http_request(client)
  puts(request)
  data = handle_request(request)
  client.puts(data)
  client.close
end
