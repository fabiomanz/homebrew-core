class Tinyice < Formula
  desc "Modern, all-in-one Icecast-compatible audio/video streaming server"
  homepage "https://datanoisetv.github.io/tinyice/"
  url "https://github.com/DatanoiseTV/tinyice/archive/refs/tags/v2.8.0.tar.gz"
  sha256 "70bf8b1ada76938a8326727da316977109b5ad236e51735e14520318c7296195"
  license "Apache-2.0"
  head "https://github.com/DatanoiseTV/tinyice.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "11a110d4f5ebed1e3d7fc95c283d5d9241bd5ee8ac71c1c32579249582b6d678"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "11a110d4f5ebed1e3d7fc95c283d5d9241bd5ee8ac71c1c32579249582b6d678"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "11a110d4f5ebed1e3d7fc95c283d5d9241bd5ee8ac71c1c32579249582b6d678"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "d30b34e8018c8fa6ecd485cbed1a7a8dc173cba7d0b1a67f64675a6ad2e5420f"
    sha256 cellar: :any,                 x86_64_linux:      "83cebb2a42b825ca460e98d4ef3e1b2c298799ebf07a3bfebfe76a1cccd08827"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -X main.Version=#{version}
      -X main.Commit=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:)
  end

  service do
    run [opt_bin/"tinyice"]
    keep_alive true
    working_dir var/"tinyice"
    log_path var/"log/tinyice.log"
    error_log_path var/"log/tinyice.log"
  end

  test do
    port = free_port

    # Write minimal config
    (testpath/"tinyice.json").write <<~JSON
      {
        "bind_host": "127.0.0.1",
        "port": "#{port}",
        "admin_user": "admin",
        "admin_password": "test"
      }
    JSON

    pid = spawn bin/"tinyice", chdir: testpath
    sleep 3

    begin
      output = shell_output("curl -s --fail http://127.0.0.1:#{port}/")
      assert_match("TinyIce", output)
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
