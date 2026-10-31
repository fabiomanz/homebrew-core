class Ipsw < Formula
  desc "Research tool for iOS & macOS devices"
  homepage "https://blacktop.github.io/ipsw"
  url "https://github.com/blacktop/ipsw/archive/refs/tags/v3.1.740.tar.gz"
  sha256 "0bf6ecce3031a79b600fbc6f5e9fa55635b4f2f3474890ccf571f87332c05c8c"
  license "MIT"
  head "https://github.com/blacktop/ipsw.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "5b5cf2b88afee19f9bb963783efb2c0fee0765da091878655742b50ebecb77a6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c2cafaaaeb1c741bdd95fbf2e893e52e53987e66408aa4b15c21a75d38b9f4b8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "5adbd5c942f2b17f02f4741defd46aa93007a951fe1682f17a17fa95a30df3b4"
    sha256 cellar: :any,                 arm64_linux:       "17819207f326fcb5b8e4ebf615d5610d56ebb9ddf0b961003fba9a68a67f17f2"
    sha256 cellar: :any,                 x86_64_linux:      "4027024d5dfa38ceebba4e144249eba7a123a73c28e237135e4a7454ed6ae979"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    ldflags = %W[
      -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppVersion=#{version}
      -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppBuildCommit=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/ipsw"
    generate_completions_from_executable(bin/"ipsw", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ipsw version")

    assert_match "iPad Pro (12.9-inch) (6th gen)", shell_output("#{bin}/ipsw device-list")
  end
end
