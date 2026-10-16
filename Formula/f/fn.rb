class Fn < Formula
  desc "Command-line tool for the fn project"
  homepage "https://fnproject.io"
  url "https://github.com/fnproject/cli/archive/refs/tags/0.6.72.tar.gz"
  sha256 "22b09812f8c4af610a50b45546e53d1096b438ca82d43e95f2604df42b7c2b24"
  license "Apache-2.0"
  head "https://github.com/fnproject/cli.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "2bdce1f9bf61c705d980689dcc1d5f8eb932aed5a682e42dc552786e4ec79368"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "2bdce1f9bf61c705d980689dcc1d5f8eb932aed5a682e42dc552786e4ec79368"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "2bdce1f9bf61c705d980689dcc1d5f8eb932aed5a682e42dc552786e4ec79368"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "2cb0f1b00fd9a50c5e9651ad7a881678b1ff59e0ba83d670b691391f83d145c4"
    sha256 cellar: :any,                 x86_64_linux:      "f2c726bc7f3b4e67ce9a760801aa911a174d3e24651546aa39153665c39ff5c9"
  end

  depends_on "go" => [:build, :test]

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fn --version")
    system bin/"fn", "init", "--runtime", "go", "--name", "myfunc"
    assert_path_exists testpath/"func.go", "expected file func.go doesn't exist"
    assert_path_exists testpath/"func.yaml", "expected file func.yaml doesn't exist"
    port = free_port
    server = TCPServer.new("localhost", port)
    pid = fork do
      loop do
        response = {
          id:         "01CQNY9PADNG8G00GZJ000000A",
          name:       "myapp",
          created_at: "2018-09-18T08:56:08.269Z",
          updated_at: "2018-09-18T08:56:08.269Z",
        }.to_json

        socket = server.accept
        socket.gets
        socket.print "HTTP/1.1 200 OK\r\n" \
                     "Content-Length: #{response.bytesize}\r\n" \
                     "Connection: close\r\n"
        socket.print "\r\n"
        socket.print response
        socket.close
      end
    end
    sleep 1
    begin
      ENV["FN_API_URL"] = "http://localhost:#{port}"
      ENV["FN_REGISTRY"] = "fnproject"
      expected = "Successfully created app:  myapp"
      output = shell_output("#{bin}/fn create app myapp")
      assert_match expected, output.chomp
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
