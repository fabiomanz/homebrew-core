class Deck < Formula
  desc "Creates slide deck using Markdown and Google Slides"
  homepage "https://github.com/k1LoW/deck"
  url "https://github.com/k1LoW/deck/archive/refs/tags/v1.24.3.tar.gz"
  sha256 "629a7c6917ba618091db0fc41bbaa85345bf1a64948439e17b26a082dd67c351"
  license "MIT"
  head "https://github.com/k1LoW/deck.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "b28564c8a7e491fe1fed778db18c123cec95a7bd76593f7b2b966a0e5cd05536"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "b28564c8a7e491fe1fed778db18c123cec95a7bd76593f7b2b966a0e5cd05536"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "b28564c8a7e491fe1fed778db18c123cec95a7bd76593f7b2b966a0e5cd05536"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "1e8f2fc93114acd199af773cfa3f5276e69fce5afa6bbf3e81f5e0da43ce61c5"
    sha256 cellar: :any,                 x86_64_linux:      "6cdefe6afba803fcdb55a4f5d6babe45b7654e266997d32e33c6dd928ce37e0c"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args, "./cmd/deck"

    generate_completions_from_executable(bin/"deck", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/deck --version")
    assert_match "presentation ID is required", shell_output("#{bin}/deck export 2>&1", 1)
  end
end
