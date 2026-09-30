class Skillshare < Formula
  desc "Sync skills across AI CLI tools"
  homepage "https://skillshare.runkids.cc"
  url "https://github.com/runkids/skillshare/archive/refs/tags/v0.22.1.tar.gz"
  sha256 "c89b889c02bef0c118ce885b03e845c418b49ce1572b347a63f95a0b8d96589a"
  license "MIT"
  head "https://github.com/runkids/skillshare.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "69b730803303ad25804616fcdd07bc2420cde2b29c530e6fe6dc296d30d4f8ed"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "69b730803303ad25804616fcdd07bc2420cde2b29c530e6fe6dc296d30d4f8ed"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "69b730803303ad25804616fcdd07bc2420cde2b29c530e6fe6dc296d30d4f8ed"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "bcd65ef634ce689e67ee666d5de290ca0619f6fe36c7b03211546dcf9fe29087"
    sha256 cellar: :any,                 x86_64_linux:      "c55ffe342a359d6b2b192d301c9f8d9521ccddf523e20ee3fd04b7d7c73e7da0"
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
