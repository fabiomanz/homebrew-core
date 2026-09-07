class NetworkDoctor < Formula
  desc "Network troubleshooting TUI"
  homepage "https://github.com/heymaikol/network-doctor/"
  url "https://github.com/heymaikol/network-doctor/archive/refs/tags/v1.16.2.tar.gz"
  sha256 "b486bfe5122e5142375cbf6eae94cccb8309d585ba5c52b3607b3aa9c7d7cb52"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "de4bca0ac31de2dd832d045b6230893c8effd63e027508c57cd84a3b6e0244a3"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "de4bca0ac31de2dd832d045b6230893c8effd63e027508c57cd84a3b6e0244a3"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "de4bca0ac31de2dd832d045b6230893c8effd63e027508c57cd84a3b6e0244a3"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "cb27cb944eed8e133e661242dc406865d15c3974fa5fd0968f4db44f150390a9"
    sha256 cellar: :any,                 x86_64_linux:  "0340c0695d37403427b0bb538a9af3bc34d7c6949a43ae80d3109a34449d74e0"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}", output: bin/"netdoc")
  end

  test do
    output = JSON.parse shell_output("#{bin}/netdoc -json")
    assert_equal version.to_s, output["version"]
    assert_equal true, output["checks"].any? { |hash| hash["id"] == "iface" && hash["status"] == "PASS" }
  end
end
