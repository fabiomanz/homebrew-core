class Evnx < Formula
  desc "Comprehensive CLI tool for managing .env files"
  homepage "https://evnx.dev"
  url "https://github.com/urwithajit9/evnx/archive/refs/tags/v0.10.4.tar.gz"
  sha256 "5f19d6cb5b0249559f8a58e55c2a1a6a88d41dcc14b395c2166a1bcc639318e8"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "afb838790d31b33d704d8654e79d326742a970f0cb915008299cd6a926d9d8d5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "3b10d2a324345607009bc9df33e8b2eceed1ba11d2ad9d784e12547064ba0dc2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "6764d620f0e13cdc026f014e998251e3239d3d04182e31d09ac1ca5bc8297429"
    sha256 cellar: :any,                 arm64_linux:       "4ba2d72c3fac93ffe21e94872d2ee819becd0421b897e8b4accd3e28778443ff"
    sha256 cellar: :any,                 x86_64_linux:      "e0e964871f3a85b8499f12e41208143e22dad2cfeaace8dbb9d074924b98f733"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/evnx --version")

    system bin/"evnx", "init", "--yes"
    assert_path_exists testpath/".env"
    assert_match "All checks passed", shell_output("#{bin}/evnx validate")

    (testpath/".env.example").append_lines "API_KEY="
    assert_match "Validation failed", shell_output("#{bin}/evnx validate 2>&1", 1)
  end
end
