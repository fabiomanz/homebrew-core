class Evnx < Formula
  desc "Comprehensive CLI tool for managing .env files"
  homepage "https://evnx.dev"
  url "https://github.com/urwithajit9/evnx/archive/refs/tags/v0.10.10.tar.gz"
  sha256 "b6e98ea0d990b88cf8bf794d68e1260bcce272522aab20a028a326693adb0846"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "003648a51e1904038447037bad82aa44365947d670e724df361a4207e44ed0e9"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "daf99bf225e0826c8bcabf0d1304b807626ca98f63c807cfc46f76c031c58f1c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "1794a14f90b1ec41637d69a3af956f7a1ee83a77a551c40b8792cadf989df3e2"
    sha256 cellar: :any,                 arm64_linux:       "e668c90e23ba5f1f18bb912a9eda077505336e2cc1a046dd2434f0d8a62e1300"
    sha256 cellar: :any,                 x86_64_linux:      "7328cd4dae069854c780b0b461d5747ebf52fed797fd7634141a5f567fbb09cc"
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
