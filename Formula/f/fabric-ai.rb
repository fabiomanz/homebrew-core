class FabricAi < Formula
  desc "Open-source framework for augmenting humans using AI"
  homepage "https://github.com/danielmiessler/fabric"
  url "https://github.com/danielmiessler/fabric/archive/refs/tags/v1.4.527.tar.gz"
  sha256 "862340b171dadcfd50845eb9240827420288c59b26cb3e19ef5c4542c3efe116"
  license "MIT"
  head "https://github.com/danielmiessler/fabric.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "ae70e9f05fb6c2228e7b24dd78c6be4544d9fa19661efe8c9267c7cfb2473aa7"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "ae70e9f05fb6c2228e7b24dd78c6be4544d9fa19661efe8c9267c7cfb2473aa7"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "ae70e9f05fb6c2228e7b24dd78c6be4544d9fa19661efe8c9267c7cfb2473aa7"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "bc16b89e598d878b690a1004845dbb3cefbfa550e74b914b0cc63de3056c195b"
    sha256 cellar: :any,                 x86_64_linux:      "e24767d7b60d2866bb957835a6280eba724cc4594d4dcb38d6c38391427a3d81"
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
