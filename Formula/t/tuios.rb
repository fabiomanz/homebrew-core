class Tuios < Formula
  desc "Terminal UI OS (Terminal Multiplexer)"
  homepage "https://tuios.gaurav.zip/"
  url "https://github.com/Gaurav-Gosain/tuios/archive/refs/tags/v0.8.3.tar.gz"
  sha256 "c9353dc67572991623e8ae2510452b6d4ac5fcd145b463171d10234eb8f38776"
  license "MIT"
  head "https://github.com/Gaurav-Gosain/tuios.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "7273ca3e5fa494f65ec896e220aba2954ab121ad1411713c0c7c795bc4232105"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "fbb1c8fc9d489bb187d84d58415f5c159311ecafd80f4c82c2ec4b6c333fca7f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "113e547f6b77210f347d24b1004835fa358dc5993105ce6548de29de8a708ed1"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "b2c777ccc0e17f268d38c2f22d9e90a7d7c2ad54eb7f35a3e42ff599482fb3b9"
    sha256 cellar: :any,                 x86_64_linux:      "1fdca88438c35bc57bfed9af612abd3865b2a928b9d7db856d2b7b446ad4a5db"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/tuios"

    generate_completions_from_executable(bin/"tuios", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tuios --version")

    assert_match "git_hub_dark", shell_output("#{bin}/tuios --list-themes")
  end
end
