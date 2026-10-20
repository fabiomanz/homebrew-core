class OhMyPosh < Formula
  desc "Prompt theme engine for any shell"
  homepage "https://ohmyposh.dev"
  url "https://github.com/JanDeDobbeleer/oh-my-posh/archive/refs/tags/v31.9.0.tar.gz"
  sha256 "aafa0b283cc6647f614e54a24755c3b92cdeac759f3538aabd192ed650f4d17c"
  license "MIT"
  head "https://github.com/JanDeDobbeleer/oh-my-posh.git", branch: "main"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "7cd6571ed51833b26eb8801bfe3f238db1087dd2a5fc9c7de348305b774b9fd4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "3d780ec2683a91aaf9e89d06b3238a9ae155bded74045a7eba68aa0e0e7f0b09"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "7166ee6f68d45965f66f4fb59ca0534de246555b77c19e8230cddb0c773536d4"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "af99e8b6ec7e5e0eaa0ac3eb4a838ca2bddb2f20f37bf7a1c4adc8c9c4e29818"
    sha256 cellar: :any,                 x86_64_linux:      "b96a4d16bd44352cc076c8f4ea27510cb67b6e8fd191a2252d5c1bde3ee2de9f"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download", "-C", "src"
  end

  def install
    ldflags = %W[
      -X github.com/jandedobbeleer/oh-my-posh/src/build.Version=#{version}
      -X github.com/jandedobbeleer/oh-my-posh/src/build.Date=#{time.iso8601}
    ]

    cd "src" do
      system "go", "build", *std_go_args(ldflags:)
    end

    prefix.install "themes"
    pkgshare.install_symlink prefix/"themes"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/oh-my-posh version")
    output = shell_output("#{bin}/oh-my-posh init bash")
    assert_match(%r{.cache/oh-my-posh/init\.\d+\.sh}, output)
  end
end
