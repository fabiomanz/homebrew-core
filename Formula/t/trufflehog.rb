class Trufflehog < Formula
  desc "Find and verify credentials"
  homepage "https://trufflesecurity.com/"
  url "https://github.com/trufflesecurity/trufflehog/archive/refs/tags/v3.99.6.tar.gz"
  sha256 "5ccae9dee11d5822a522c92f1b69b43639350b84ff6353c33d0df38c75bdc5af"
  # upstream license ask, https://github.com/trufflesecurity/trufflehog/issues/1446
  license "AGPL-3.0-only"
  head "https://github.com/trufflesecurity/trufflehog.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "593d1a830e817c435b08562043ba2ee65dfefe57812689d944515abbc89de268"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "8a8a391a29d6032fd491431498e5ccb2d12714d7a2b74c79fd47ef05ff8f858b"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "3ad77d958360567d3ae60195ce0ac3f42434d574603aa9eb966190d8cc943952"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "0628f360e931f75222e436b423417b100ee55c727e87bda9eb3b1eb87509904c"
    sha256 cellar: :any,                 x86_64_linux:      "5e7a08a74b5d6afad1fc46ebe20ee977017bdcbeade948651e3ea50ba073de2c"
  end

  depends_on "go" => :build

  # `test do` block scans a GitHub repository
  allow_network_access! :test

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = "-X github.com/trufflesecurity/trufflehog/v3/pkg/version.BuildVersion=#{version}"
    system "go", "build", *std_go_args(ldflags:)
    man1.install "docs/man/trufflehog.1"
  end

  test do
    repo = "https://github.com/trufflesecurity/test_keys"
    output = shell_output("#{bin}/trufflehog git #{repo} --no-update --only-verified 2>&1")
    expected = "{\"chunks\": 0, \"bytes\": 0, \"verified_secrets\": 0, \"unverified_secrets\": 0, \"scan_duration\":"
    assert_match expected, output

    assert_match version.to_s, shell_output("#{bin}/trufflehog --version 2>&1")
  end
end
