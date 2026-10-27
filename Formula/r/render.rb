class Render < Formula
  desc "Command-line interface for Render"
  homepage "https://render.com/docs/cli"
  url "https://github.com/render-oss/cli/archive/refs/tags/v2.32.0.tar.gz"
  sha256 "3967ccb195c9b68116f9f0058138698490460963b4f113677d6df5cbf461a98c"
  license "Apache-2.0"
  head "https://github.com/render-oss/cli.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "e854c5416ac398a8350a121860363a89e4974b7ee0bea041c0ed018a5786e367"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "e854c5416ac398a8350a121860363a89e4974b7ee0bea041c0ed018a5786e367"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "e854c5416ac398a8350a121860363a89e4974b7ee0bea041c0ed018a5786e367"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "66c0ba8c890d743630e919852de41bc7cf123a4f5c8130c127fc095c2c4ce533"
    sha256 cellar: :any,                 x86_64_linux:      "8029650d569998d202a32b8b3f4d9638bd2675151e0eb7d579c1b2cf701fc6a7"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[-X github.com/render-oss/cli/pkg/cfg.Version=#{version}]
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/render --version")

    output = shell_output("#{bin}/render services -o json 2>&1", 1)
    assert_match "Error: no workspace set. Use `render workspace set` to set a workspace", output
  end
end
