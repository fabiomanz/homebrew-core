class Gomi < Formula
  desc "Functions like rm but with the ability to restore files"
  homepage "https://gomi.dev"
  url "https://github.com/babarot/gomi/archive/refs/tags/v1.8.0.tar.gz"
  sha256 "514019cc7f87cb19f1a7c2dafd3fffaf29b3239d805f7ff8f92375124a15c1eb"
  license "MIT"
  head "https://github.com/babarot/gomi.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "5190187f841fbd660c9e655c3fecd38679f08428ff8c924084c219ee5172dfa0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "5190187f841fbd660c9e655c3fecd38679f08428ff8c924084c219ee5172dfa0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "5190187f841fbd660c9e655c3fecd38679f08428ff8c924084c219ee5172dfa0"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "f671e5c5997900823401deef4d76a301b493a8cb40932860b2bb52b4add3d96e"
    sha256 cellar: :any,                 x86_64_linux:      "0a137547c0b5cd7209b74a344723c688080b0ff68f1fbcd791e7aa666dbe310d"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X main.version=v#{version}
      -X main.revision=#{tap.user}
      -X main.buildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    ENV["TMPDIR"] = testpath

    # Create a trash directory
    mkdir ".gomi"

    assert_match version.to_s, shell_output("#{bin}/gomi --version")

    (testpath/"trash").write <<~TEXT
      Homebrew
    TEXT

    # Restoring is done in an interactive prompt, so we only test deletion.
    assert_path_exists testpath/"trash"
    system bin/"gomi", "trash"
    refute_path_exists testpath/"trash"
  end
end
