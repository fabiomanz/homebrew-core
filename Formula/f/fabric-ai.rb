class FabricAi < Formula
  desc "Open-source framework for augmenting humans using AI"
  homepage "https://github.com/danielmiessler/fabric"
  url "https://github.com/danielmiessler/fabric/archive/refs/tags/v1.4.523.tar.gz"
  sha256 "22a05e2c8025350ae63e3f9b2b802be020837f505a459f87fb03871466abe111"
  license "MIT"
  head "https://github.com/danielmiessler/fabric.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "653678f1d035578c590eb0c49b0fbdee7119a35eb06a4b30bd53dd1326e32ffe"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "653678f1d035578c590eb0c49b0fbdee7119a35eb06a4b30bd53dd1326e32ffe"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "653678f1d035578c590eb0c49b0fbdee7119a35eb06a4b30bd53dd1326e32ffe"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "a7dce4872d818a1d2a0c97f82349790afa63bc2986fa40c2883fb6f5f481ab4f"
    sha256 cellar: :any,                 x86_64_linux:      "fbf7fc99fd373087d0792f7e56fb9f02acf8c0ea991f23d1a7bae7ec89cbce39"
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
