class Sonic < Formula
  desc "Fast, lightweight & schema-less search backend"
  homepage "https://github.com/valeriansaliou/sonic"
  url "https://github.com/valeriansaliou/sonic/archive/refs/tags/v1.9.0.tar.gz"
  sha256 "4ce52d4bcb5411eb11a78648ed466bad938abedba1f20c4f17397108c23306b7"
  license "MPL-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "cc2c86807f17ccc0172887722822dbb1613944e22f7324393a08afa8bb2df0e3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "7944100f15990a407495fdd5af647d7c8db208ee705ca70c633c9d6a7035edaa"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "e7e26d2b4e16f863ecc12a104fbbe926385195e5f22c6e623de788a08320f653"
    sha256 cellar: :any,                 arm64_linux:       "2bddc8accb772d356576c1f20ff43d1f9020d9c9a49f4e2d5489e178a34b97f0"
    sha256 cellar: :any,                 x86_64_linux:      "38ef42be0c377e65ad5a43da3840701c3b70111196b96bc630ffe35b7919ec48"
  end

  depends_on "rust" => :build

  uses_from_macos "llvm" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "server")
    inreplace "config.cfg", "./", var/"sonic/"
    etc.install "config.cfg" => "sonic.cfg"
  end

  service do
    run [opt_bin/"sonic", "-c", etc/"sonic.cfg"]
    keep_alive true
    working_dir var
    log_path var/"log/sonic.log"
    error_log_path var/"log/sonic.log"
  end

  test do
    port = free_port

    cp etc/"sonic.cfg", testpath/"config.cfg"
    inreplace "config.cfg", "[::1]:1491", "0.0.0.0:#{port}"
    inreplace "config.cfg", "#{var}/sonic", "."

    pid = spawn bin/"sonic"
    sleep 10
    TCPSocket.open("localhost", port) do |sock|
      assert_match "CONNECTED", sock.gets
      sock.puts "START ingest SecretPassword"
      assert_match "STARTED ingest protocol(1)", sock.gets
      sock.puts 'PUSH messages user:0dcde3a6 conversation:71f3d63b "Hello world!"'
      assert_match "OK", sock.gets
      sock.puts "QUIT"
      assert_match "ENDED", sock.gets
    end
  ensure
    Process.kill "TERM", pid
    Process.wait pid
  end
end
