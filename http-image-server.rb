require 'socket'

def read_line(socket)
  loop do
    line = socket.gets
    return line unless line.nil?
    sleep(0.01)
  end
end

def parse_http_request(socket)
  request = {}

  # GET /favicon.ico HTTP/1.1
  line = read_line(socket)
  tmp = line.split(/\s+/)
  request[:method]   = tmp[0]
  request[:path]     = tmp[1]
  request[:protocol] = tmp[2]

  headers = {}
  while line = read_line(socket)
    line.strip!
    break if line.empty?
    # Connection: keep-alive
    tmp = line.split(':')
    headers[tmp[0].strip()] = tmp[1].strip()
  end
  request[:headers] = headers

  request
end

def handle_image(request)
  # path = /images/tcp-001.jpg => images/tcp-001.jpg
  path = request[:path].gsub(/^\//, "")
  ext = File.extname(path).gsub(/^\./, "")
  if File.exist?(path)
    {
      status: 200,
      content_type: "image/#{ext}",
      body: File.read(path)
    }
  else
    {status: 404, body: ""}
  end
end

def handle_request(request)
  if (request[:path].start_with?("/images/"))
    handle_image(request)
  elsif (request[:path] == "/test-1")
    {
      status: 200,
      content_type: "text/html; charset=utf-8",
      body: "<h1>TEST 1</h1>"
    }
  else
    {
      status: 200,
      content_type: "text/html; charset=utf-8",
      body: "<h1>path - #{request[:path]}</h1>"
    }
  end
end

def make_response(response)
  message = response[:status] >= 200 && response[:status] < 300 ? "OK" : "ERROR"
  "HTTP/1.1 #{response[:status]} #{message}\n" +
  "Date: #{Time.now}\n" +
  "Server: My Awesome Server\n" +
  "X-Powered-By: Ruby/2.4.0\n" +
  "Last-Modified: #{Time.now}\n" +
  "Content-Language: ru\n" +
  "Content-Type: #{response[:content_type]}\n" +
  "Content-Length: #{response[:body].length}\n" +
  "Connection: close\n\n" +
  response[:body]
end

server = TCPServer.new 2000 # Server bind to port 2000
loop do
  client = server.accept    # Wait for a client to connect
  request = parse_http_request(client)
  response = handle_request(request)
  data = make_response(response)
  client.puts(data)
  client.close
end
