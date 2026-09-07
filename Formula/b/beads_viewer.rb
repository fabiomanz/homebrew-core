class BeadsViewer < Formula
  desc "Terminal-based UI for the Beads issue tracker"
  homepage "https://github.com/Dicklesworthstone/beads_viewer"
  url "https://github.com/Dicklesworthstone/beads_viewer/archive/refs/tags/v0.24.0.tar.gz"
  sha256 "b28f0d8fd2353baf294ba8001511aa3c8335e5c2a10401b261601cd50e7b1cce"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "abf2298b1fa943beabb66d172c8c89a123ad8592425069b4a27aba3d4cbc77f3"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "abf2298b1fa943beabb66d172c8c89a123ad8592425069b4a27aba3d4cbc77f3"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "abf2298b1fa943beabb66d172c8c89a123ad8592425069b4a27aba3d4cbc77f3"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "11cd39e49fec24edf08907250f425e7823e32e92ee0b56522a4d1c4507ec8f7e"
    sha256 cellar: :any,                 x86_64_linux:  "a33ae98ffa41db44a3398b4da977082af4a5774e2c9d109f20ce054c54263c08"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[-X github.com/Dicklesworthstone/beads_viewer/pkg/version.version=v#{version}]
    system "go", "build", *std_go_args(ldflags:, output: bin/"bv"), "./cmd/bv"
  end

  test do
    assert_match "v#{version}", shell_output("#{bin}/bv --version")

    # Test that it detects missing .beads directory.
    output = shell_output("#{bin}/bv --robot-insights 2>&1", 1)
    assert_match "failed to read beads directory", output
  end
end
