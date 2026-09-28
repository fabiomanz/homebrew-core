class EnpassCli < Formula
  desc "Enpass command-line client"
  homepage "https://github.com/hazcod/enpass-cli"
  url "https://github.com/hazcod/enpass-cli/archive/refs/tags/v1.13.0.tar.gz"
  sha256 "dda2d9bb79a1fc9edb5318e61d6aec409308a3d89a6996bbcd1d3cc65b3c9b67"
  license "MIT"
  head "https://github.com/hazcod/enpass-cli.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "eda2aaff9fc497f3f6fb99a2353586a4f189ebad282faad013ed4b6a8c50aa7b"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "666dee84b5bcba4f9bb0c29f8818f7115441b1a9e2fb0f9435a826b07d7b629a"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "7f539ddc03da5eb395192b356199a996e1fa3d45d38a3256405673fcd74872db"
    sha256 cellar: :any,                 arm64_linux:       "8d868b9d00bd0787d1017b1306fe932f477f2c311d8ab3814bd63e3b17b0acf3"
    sha256 cellar: :any,                 x86_64_linux:      "c4e0518a5ab0d45439b604e6140d9f8b2539171aaee1288963c8d2f4576896eb"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["CGO_ENABLED"] = "1"
    system "go", "build", *std_go_args(ldflags: "-X 'main.version=#{version}'"), "./cmd/enpasscli"
    pkgshare.install "test/vault.json", "test/vault.enpassdb"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/enpass-cli version 2>&1")

    # Get test vault files
    mkdir "testvault"
    cp [pkgshare/"vault.json", pkgshare/"vault.enpassdb"], "testvault"
    # Master password for test vault
    ENV["MASTERPW"] = "absolutely-No-clue"
    # Retrieve password for "johndoe" from test vault
    assert_match "noIdeaata11", shell_output("#{bin}/enpass-cli -vault testvault/ pass johndoe").chomp
  end
end
