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

  def sh_bg(cmd)
    silence_stream($stdout) do
      silence_stream($stderr) do
        (pid = fork) ? Process.detach(pid) : exec("#{cmd} 2>&1>/dev/null")
      end
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

  def wait_for_service(host, port, timeout = 5)
    start_time = Time.now

    until listening?(host, port)
      if timeout && (Time.now > (start_time + timeout))
        raise SocketError.new("Socket did not open within #{timeout} seconds")
      end
    end

    true
  end

  def suspects(port)
    sh("lsof -i :#{port}").first.split("\n")[1..-1].map {|s| s[/^.+? (\d+)/, 1] }
  end

  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen(RUBY_PLATFORM =~ /mswin/ ? 'NUL:' : '/dev/null')
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
  end
end
