class Zot < Formula
  desc "Lightweight coding agent harness written in Go"
  homepage "https://www.zot.sh/"
  url "https://github.com/patriceckhart/zot/archive/refs/tags/v0.4.12.tar.gz"
  sha256 "e7ef2a68152563339bb8f69e6e15b181a241f2c17569a4b30f3118bb3040ac0b"
  license "MIT"
  head "https://github.com/patriceckhart/zot.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "256c2e26bc47114118787229e796720e31cddb9baf4c6cfbe432702bd1853816"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "256c2e26bc47114118787229e796720e31cddb9baf4c6cfbe432702bd1853816"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "256c2e26bc47114118787229e796720e31cddb9baf4c6cfbe432702bd1853816"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "f60b7e1676e29e529a6880e31899eaf1d4853e2bd4a798f9ffe1c1752ce8d0e8"
    sha256 cellar: :any,                 x86_64_linux:      "2d201ef20fc083ea3db8ce862dd07e62db248f80ca7bcceb84bfb2e2d098f2c4"
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
