require "open3"
require "socket"

module Test::Commands
  def sh(cmd)
    out, err = nil

    Open3.popen3(cmd) do |_in, _out, _err|
      out = _out.read
      err = _err.read
    end

    [out, err]
  end

  # Runs a command in the background, silencing all output.
  # For debugging purposes, set the environment variable VERBOSE.
  def sh_bg(cmd)
    if ENV["VERBOSE"]
      streams_to_silence = []
    else
      streams_to_silence = [$stdout, $stderr]
      cmd = "#{cmd} 2>&1>/dev/null"
    end

    silence_stream(*streams_to_silence) do
      (pid = fork) ? Process.detach(pid) : exec(cmd)
    end
  end

  def listening?(host, port)
    begin
      socket = TCPSocket.new(host, port)
      socket.close unless socket.nil?
      true
    rescue Errno::ECONNREFUSED,
      Errno::EBADF,           # Windows
      Errno::EADDRNOTAVAIL    # Windows
      false
    end
  end

  def wait_for_service(host, port, timeout = 3)
    start_time = Time.now

    until listening?(host, port)
      if timeout && (Time.now > (start_time + timeout))
        raise SocketError.new("Socket #{host}:#{port} did not open within #{timeout} seconds")
      end
    end

    true
  end

  def suspects(port)
    list = sh("lsof -i :#{port}").first.split("\n")[1..-1] || []
    list.map {|s| s[/^.+? (\d+)/, 1] }
  end

  def silence_stream(*streams) #:yeild:
    on_hold = streams.collect{ |stream| stream.dup }
    streams.each do |stream|
      stream.reopen(RUBY_PLATFORM =~ /mswin/ ? 'NUL:' : '/dev/null')
      stream.sync = true
    end
    yield
  ensure
    streams.each_with_index do |stream, i|
      stream.reopen(on_hold[i])
    end
  end
end
