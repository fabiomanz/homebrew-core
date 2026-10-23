class FabricAi < Formula
  desc "Open-source framework for augmenting humans using AI"
  homepage "https://github.com/danielmiessler/fabric"
  url "https://github.com/danielmiessler/fabric/archive/refs/tags/v1.4.549.tar.gz"
  sha256 "7ec6451d0dd00b274e961d5a99f8f2acd9f6e20f51d55be680798a5b13d722b8"
  license "MIT"
  head "https://github.com/danielmiessler/fabric.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "1123c0040082bc9eadec6fb222c80f8272f512e5b99e5da2c91f73b1db48b47e"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "1123c0040082bc9eadec6fb222c80f8272f512e5b99e5da2c91f73b1db48b47e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "1123c0040082bc9eadec6fb222c80f8272f512e5b99e5da2c91f73b1db48b47e"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "cea3dc8733db28f2ef904d650fb0106a92dedcbd820278a8a7b5c14d286c57ba"
    sha256 cellar: :any,                 x86_64_linux:      "087d313b89c269281ce885c42e35314eef28e580e4b17dab4f3b7fc3afbb3c4b"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/fabric"
    # Install completions
    bash_completion.install "completions/fabric.bash" => "fabric-ai"
    fish_completion.install "completions/fabric.fish" => "fabric-ai.fish"
    zsh_completion.install "completions/_fabric" => "_fabric-ai"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fabric-ai --version")

    (testpath/".config/fabric/.env").write("t\n")
    output = pipe_output("#{bin}/fabric-ai --dry-run 2>&1", "", 1)
    assert_match "error loading .env file: unexpected character", output
  end
end
