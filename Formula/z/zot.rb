class Zot < Formula
  desc "Lightweight coding agent harness written in Go"
  homepage "https://www.zot.sh/"
  url "https://github.com/patriceckhart/zot/archive/refs/tags/v0.4.36.tar.gz"
  sha256 "0ab5f8b898695033d974a568b126d9a72440204b17bdae450ffecdd6fb807140"
  license "MIT"
  head "https://github.com/patriceckhart/zot.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "afcb84a20514dd99335429cfdaa373119eedafc02a57461a9af6ca05152d9258"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "afcb84a20514dd99335429cfdaa373119eedafc02a57461a9af6ca05152d9258"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "afcb84a20514dd99335429cfdaa373119eedafc02a57461a9af6ca05152d9258"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "ff48fc2ce7105836ad48808ff4fb9e271f56ecfb6deb49742722f950657c6121"
    sha256 cellar: :any,                 x86_64_linux:      "91b2824145041b1fabcf8c47111222426c5087bd150d070a1ea6584f9d932cbf"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/zot"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/zot --version")
    assert_match "zot: no credential for anthropic", shell_output("#{bin}/zot rpc 2>&1", 1)
  end
end
