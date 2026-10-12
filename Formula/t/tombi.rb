class Tombi < Formula
  desc "TOML formatter, linter and language server"
  homepage "https://github.com/tombi-toml/tombi"
  url "https://github.com/tombi-toml/tombi/archive/refs/tags/v1.8.2.tar.gz"
  sha256 "00bf6e004d2fc56a79fd5b95a0fc01245157175fac3420504348d872096015d5"
  license "MIT"
  head "https://github.com/tombi-toml/tombi.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_releases
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "92ba213f484d3e4ae77a2c64f9b8c018bf4ea0b611e0d0affa02d380feddadd5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "ed8aae349b44991d78e035d4f0748d64f0dcc51806b0718f9510613a1e350744"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "744ee486acaba84a1330d2f0d515f8c37224c5e79b136fb9d53526189a6a9c25"
    sha256 cellar: :any,                 arm64_linux:       "b336deb46ebfac69671054bb90ebcd90b4a31ad4211aa8206feab10c3a38f19f"
    sha256 cellar: :any,                 x86_64_linux:      "39d2b6cbcefbbfdeb1ecd518be1894e16b9f4a974a36725442e8d36634e4c27a"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args, "--manifest-path", "rust/tombi-cli/Cargo.toml"
  end

  def install
    ENV["TOMBI_VERSION"] = version.to_s
    system "cargo", "xtask", "set-version"
    system "cargo", "install", *std_cargo_args(path: "rust/tombi-cli")

    generate_completions_from_executable(bin/"tombi", "completion", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tombi --version")

    require "open3"

    json = <<~JSON
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "rootUri": null,
          "capabilities": {}
        }
      }
    JSON

    Open3.popen3(bin/"tombi", "lsp") do |stdin, stdout|
      stdin.write "Content-Length: #{json.size}\r\n\r\n#{json}"
      sleep 1
      assert_match(/^Content-Length: \d+/i, stdout.readline)
    end
  end
end
