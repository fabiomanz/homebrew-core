class DockerAgent < Formula
  desc "Agent Builder and Runtime by Docker Engineering"
  homepage "https://docker.github.io/docker-agent/"
  url "https://github.com/docker/docker-agent/archive/refs/tags/v1.135.0.tar.gz"
  sha256 "cb46b4b3a00957b219e2aa6c162f01bea09ab2a42258149fd0b30a2ea68c942a"
  license "Apache-2.0"
  head "https://github.com/docker/docker-agent.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "6464d1a2419d7d1e4d2026429efae88437f0b7141b702c0c76fc7f6d566d83fd"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "13af9848ca99c98ca004aab4b08df4103ea9805f6732f3c620e34c3e605947ca"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "f0d6e744f56383f143bd3bdacf8e3f54fec4e26850c2b3095dd259b9359834e4"
    sha256 cellar: :any,                 arm64_linux:   "26edc76ced3649f9b3304e9733a3069da4d05f4967ce36d14b0b0247241877e8"
    sha256 cellar: :any,                 x86_64_linux:  "4571a9a291ab2bd1a4cb024a61cff080d90f03f6de74fee63a9c11f28de696c8"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "1" if OS.linux? && Hardware::CPU.arm?

    ldflags = %W[
      -X github.com/docker/docker-agent/pkg/version.Version=v#{version}
      -X github.com/docker/docker-agent/pkg/version.Commit=#{tap.user}
    ]

    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"docker-agent", shell_parameter_format: :cobra)
  end

  test do
    (testpath/"agent.yaml").write <<~YAML
      version: "2"
      agents:
        root:
          model: openai/gpt-4o
    YAML

    assert_match("docker-agent version v#{version}", shell_output("#{bin}/docker-agent version"))
    output = shell_output("#{bin}/docker-agent run --exec --dry-run agent.yaml hello 2>&1", 1)
    assert_match(/must be set.*OPENAI_API_KEY/m, output)
  end
end
