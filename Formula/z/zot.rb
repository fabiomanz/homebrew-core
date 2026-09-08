class Zot < Formula
  desc "Lightweight coding agent harness written in Go"
  homepage "https://www.zot.sh/"
  url "https://github.com/patriceckhart/zot/archive/refs/tags/v0.3.67.tar.gz"
  sha256 "ed40c70719a88485bffdb39c268eaafd5d2ec8ab1dd9dca0f3d99ca3bac10e8e"
  license "MIT"
  head "https://github.com/patriceckhart/zot.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "acf1dd410ff19df534e7c4ef58ab8a6892f445bc7e9acd4e6d91993f8c2b2bc4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "acf1dd410ff19df534e7c4ef58ab8a6892f445bc7e9acd4e6d91993f8c2b2bc4"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "acf1dd410ff19df534e7c4ef58ab8a6892f445bc7e9acd4e6d91993f8c2b2bc4"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "a0f360bcbfffbbae2769226ba36bc3dc1ffd8e420babb2e2b0ac7d01f9281379"
    sha256 cellar: :any,                 x86_64_linux:  "7997d454e10c5385f03f51a45b2a43c3b0be51d4e4377592c483345d72719371"
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
