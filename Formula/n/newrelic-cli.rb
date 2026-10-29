class NewrelicCli < Formula
  desc "Command-line interface for New Relic"
  homepage "https://github.com/newrelic/newrelic-cli"
  url "https://github.com/newrelic/newrelic-cli/archive/refs/tags/v0.115.5.tar.gz"
  sha256 "be1b56de787b4fb0f75b1ecde484af2e960bdffeff517817e6702fea90fb0860"
  license "Apache-2.0"
  head "https://github.com/newrelic/newrelic-cli.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "27d01d55ac298bf7b77eb421772336043192564274693d91fedff3f22eed580a"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "a41fe6b016e58baf6ac252bf1d8bcb75a5ce44fd4694e33c92c3dc49c159ec79"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "05c5570ca4cf8d6ff4471fc21e10646ef4836ffaa316e280b07c7142b23ad721"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "28f0be0b5f7ed05486c1bc26372dc8a6ff94f4e0625124ca8d5ea17f4ab10fad"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "c66154a8e24821ad959ee805405a61e2b8e3c815d1c2cdc1735f49ec4d51948d"
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
