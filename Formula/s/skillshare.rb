class Skillshare < Formula
  desc "Sync skills across AI CLI tools"
  homepage "https://skillshare.runkids.cc"
  url "https://github.com/runkids/skillshare/archive/refs/tags/v0.24.2.tar.gz"
  sha256 "05e71573990e12fea5a01d47f00e253e28a2cc095c5234dfbc5e798bde10e33d"
  license "MIT"
  head "https://github.com/runkids/skillshare.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "bc9a16237f1c1171a35a8cf1ee4c40b1c0ff853610a3b203402f807907d480e5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "bc9a16237f1c1171a35a8cf1ee4c40b1c0ff853610a3b203402f807907d480e5"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "bc9a16237f1c1171a35a8cf1ee4c40b1c0ff853610a3b203402f807907d480e5"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "c29362eb324520277cd71cc335008f27ce7bfc675bb0088735bb19af18c2f736"
    sha256 cellar: :any,                 x86_64_linux:      "de50543e5a5da111b98ffc1c74f88a9aa1b965609516581b63b975ad1417d242"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    # Avoid building web UI
    ui_path = "internal/server/dist"
    mkdir_p ui_path
    (buildpath/"#{ui_path}/index.html").write "<!DOCTYPE html><html><body><h1>UI not built</h1></body></html>"

    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/skillshare"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/skillshare version")

    assert_match "config not found", shell_output("#{bin}/skillshare sync 2>&1", 1)
  end
end
