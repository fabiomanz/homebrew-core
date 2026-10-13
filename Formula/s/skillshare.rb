class Skillshare < Formula
  desc "Sync skills across AI CLI tools"
  homepage "https://skillshare.runkids.cc"
  url "https://github.com/runkids/skillshare/archive/refs/tags/v0.25.10.tar.gz"
  sha256 "e30c963e7243358f552bc8a451faaa97af3fe99e08e41ff5a703a940b86418ac"
  license "MIT"
  head "https://github.com/runkids/skillshare.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "726a2bae21f7cc99dc3478b818b577ab1f0b8c4bd13b0c911e085db142a73be8"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "726a2bae21f7cc99dc3478b818b577ab1f0b8c4bd13b0c911e085db142a73be8"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "726a2bae21f7cc99dc3478b818b577ab1f0b8c4bd13b0c911e085db142a73be8"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "6952e53b41f429f5f842dc5d28e3c198b44b9975ec8bb9799d69a44611551182"
    sha256 cellar: :any,                 x86_64_linux:      "610189b8df30f6549992ad3c60336c5cabb9b7ddd20555bd3662272e2db17e0d"
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
