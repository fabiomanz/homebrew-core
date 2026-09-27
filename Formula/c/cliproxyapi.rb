class Cliproxyapi < Formula
  desc "Wrap Gemini CLI, Codex, Claude Code, Qwen Code as an API service"
  homepage "https://github.com/router-for-me/CLIProxyAPI"
  url "https://github.com/router-for-me/CLIProxyAPI/archive/refs/tags/v7.3.20.tar.gz"
  sha256 "5ec1a413d49820a10ead8f6e04ad5417e35177667547c5a00496ac683db900e2"
  license "MIT"
  head "https://github.com/router-for-me/CLIProxyAPI.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    throttle 5
  end

  bottle do
    sha256 arm64_golden_gate: "5f9de22c0e8713232b91e268cffe40e447269d8949991c472c321d9fdc7f3fac"
    sha256 arm64_tahoe:       "b388ce76241a376653abaa3ee3e77fae8b1eb86d50172f79cff905949b88d524"
    sha256 arm64_sequoia:     "8ac5a81a668f448df40abc52a2219cadd9a6e38f4a26bfe72e10083e53433702"
    sha256 arm64_linux:       "70a41bc5320a66622fbbab9f38404ed21b6b172d2ef80b95ef9b7d9f455cd697"
    sha256 x86_64_linux:      "bca82decc0c9b28000c63fff55b73e9ed7560fe578818d508bbce07926866467"
  end

  depends_on "go" => :build

  # `test do` block needs local sockets for the login flow
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X main.Version=#{version}
      -X main.Commit=#{tap.user}
      -X main.BuildDate=#{time.iso8601}
      -X main.DefaultConfigPath=#{etc/"cliproxyapi.conf"}
    ]

    system "go", "build", *std_go_args(ldflags:), "cmd/server/main.go"
    etc.install "config.example.yaml" => "cliproxyapi.conf"
  end

  service do
    run [opt_bin/"cliproxyapi"]
    keep_alive true
  end

  test do
    require "pty"
    PTY.spawn(bin/"cliproxyapi", "-antigravity-login", "-no-browser") do |r, _w, pid|
      sleep 5
      Process.kill "TERM", pid
      assert_match "accounts.google.com", r.read_nonblock(1024)
    end
  end
end
