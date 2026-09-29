class NewrelicCli < Formula
  desc "Command-line interface for New Relic"
  homepage "https://github.com/newrelic/newrelic-cli"
  url "https://github.com/newrelic/newrelic-cli/archive/refs/tags/v0.114.1.tar.gz"
  sha256 "e13319743bfabbaac512fe7a12c11c89dc195903b7684e7db7b3a73b24107d91"
  license "Apache-2.0"
  head "https://github.com/newrelic/newrelic-cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "1f8e802449ea2345c40cda83da588beeb879b637faa7d374e93b91f6d7c4453b"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "4282d76a2f05bb4288368a459a08fc20bc4e9f160e3863eba3197cf9a62d0961"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "73725b39e47d1e3f940c4eb3fafb57527aa35f133bdd540d90b2827b974e0d75"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "12d63fafffd691115979876bd0af973371d43839fe755e1c7b4ea9472d78a5bb"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "ee130981eaaf4bdfc292dca7cd968ac5bf01c21b8980dec2fb40cbc4b0669549"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ENV["PROJECT_VER"] = version
    system "make", "compile-only"
    bin.install "bin/#{OS.kernel_name.downcase}/newrelic"

    generate_completions_from_executable(bin/"newrelic", "completion", "--shell")
  end

  test do
    output = shell_output("#{bin}/newrelic config list")

    assert_match "loglevel", output
    assert_match "plugindir", output
    assert_match version.to_s, shell_output("#{bin}/newrelic version 2>&1")
  end
end
