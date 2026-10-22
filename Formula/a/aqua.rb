class Aqua < Formula
  desc "Declarative CLI Version manager"
  homepage "https://aquaproj.github.io/"
  url "https://github.com/aquaproj/aqua/archive/refs/tags/v2.65.0.tar.gz"
  sha256 "596f4717effc711625b9bf2d52bc967b0ee8282faf3922669517d24f720c7030"
  license "MIT"
  head "https://github.com/aquaproj/aqua.git", branch: "main"

  # Upstream creates releases that use a stable tag (e.g., `v1.2.3`) but are
  # labeled as "pre-release" on GitHub before the version is released, so it's
  # necessary to use the `GithubLatest` strategy.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "2acddf51840df5565c41aefc80d1c0b8364c322245ff3c6f6890412bcb4205f6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "2acddf51840df5565c41aefc80d1c0b8364c322245ff3c6f6890412bcb4205f6"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "2acddf51840df5565c41aefc80d1c0b8364c322245ff3c6f6890412bcb4205f6"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "2b32a72a57acc0fd26f0a445901535ace04d19164d8861eb2531d28a1017b72f"
    sha256 cellar: :any,                 x86_64_linux:      "89b9779ada02d88ead6021f59294dbf127fb5b0de686327d73e24bdefe9ed0d5"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/aqua"

    generate_completions_from_executable(bin/"aqua", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aqua --version")

    system bin/"aqua", "init"
    assert_match "depName=aquaproj/aqua-registry", (testpath/"aqua.yaml").read
  end
end
