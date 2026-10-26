class Gomi < Formula
  desc "Functions like rm but with the ability to restore files"
  homepage "https://gomi.dev"
  url "https://github.com/babarot/gomi/archive/refs/tags/v1.10.0.tar.gz"
  sha256 "876c6581c18e0394d22ee24dfc2de0ba6f18752a487bea9f44511e0581540e15"
  license "MIT"
  head "https://github.com/babarot/gomi.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "8e2cbc859d5904de55dde6119f3bd8a5270a5a26dfc598c9763c22ec57ec9407"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "8e2cbc859d5904de55dde6119f3bd8a5270a5a26dfc598c9763c22ec57ec9407"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "8e2cbc859d5904de55dde6119f3bd8a5270a5a26dfc598c9763c22ec57ec9407"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "54051f257904e4623384ffcb27924e8cd0457bb4eb4baca6a997f2b9f6b8d329"
    sha256 cellar: :any,                 x86_64_linux:      "7200decf0196d8068bbd56b74d000648e4b73cda3a5df99a9fbf8cf70d81fce4"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X main.version=v#{version}
      -X main.revision=#{tap.user}
      -X main.buildDate=#{time.iso8601}
    ]
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    ENV["TMPDIR"] = testpath

    # Create a trash directory
    mkdir ".gomi"

    assert_match version.to_s, shell_output("#{bin}/gomi --version")

    (testpath/"trash").write <<~TEXT
      Homebrew
    TEXT

    # Restoring is done in an interactive prompt, so we only test deletion.
    assert_path_exists testpath/"trash"
    system bin/"gomi", "trash"
    refute_path_exists testpath/"trash"
  end
end
