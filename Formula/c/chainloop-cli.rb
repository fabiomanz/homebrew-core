class ChainloopCli < Formula
  desc "CLI for interacting with Chainloop"
  homepage "https://docs.chainloop.dev"
  url "https://github.com/chainloop-dev/chainloop/archive/refs/tags/v1.127.3.tar.gz"
  sha256 "d010bff63dcfc995c0bc6ad139f999030d3c510ce92cf99e3d5cb170e65ff1a2"
  license "Apache-2.0"
  head "https://github.com/chainloop-dev/chainloop.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "93e70bb0372c8161b99e0ba1eb2b5e2eeea4c6211b49a65c90b7062407d64efd"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "93e70bb0372c8161b99e0ba1eb2b5e2eeea4c6211b49a65c90b7062407d64efd"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "93e70bb0372c8161b99e0ba1eb2b5e2eeea4c6211b49a65c90b7062407d64efd"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "c400d5bab5402df292d1efa714751a4ccdfaec541725b40d51f5f6f67c6807cb"
    sha256 cellar: :any,                 x86_64_linux:      "98c9106bcf30663e5aeebd0c7928a9e861875e1c55af2a53f94f1012a2fd6d43"
  end

  depends_on "go" => :build

  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/chainloop-dev/chainloop/app/cli/cmd.Version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:, output: bin/"chainloop"), "./app/cli"

    generate_completions_from_executable(bin/"chainloop", shell_parameter_format: :cobra)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/chainloop version 2>&1")

    output = shell_output("#{bin}/chainloop artifact download 2>&1", 1)
    assert_match "chainloop auth login", output
  end
end
