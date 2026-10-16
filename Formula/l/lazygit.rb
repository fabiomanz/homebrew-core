class Lazygit < Formula
  desc "Simple terminal UI for git commands"
  homepage "https://github.com/jesseduffield/lazygit/"
  url "https://github.com/jesseduffield/lazygit/archive/refs/tags/v0.66.1.tar.gz"
  sha256 "75d82496e7e99a4ae58279efd37186ee5d10de9bb751077775487639c07185af"
  license "MIT"
  head "https://github.com/jesseduffield/lazygit.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "4be1775972ff7a776d8b1632e5760df7449adfbb23364f33079d05259a2a32f3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "4be1775972ff7a776d8b1632e5760df7449adfbb23364f33079d05259a2a32f3"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "4be1775972ff7a776d8b1632e5760df7449adfbb23364f33079d05259a2a32f3"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "2c0c70ed94468abd34146359e1bb3da0f19b9966c3dbc0e3f5c4afa05d0a9182"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "654d9452762d7342c13d5e28bc61e680a6055980d85a60b1683ffc8280c86fb4"
  end

  depends_on "go" => :build

  deny_network_access!

  def install
    ENV["CGO_ENABLED"] = OS.mac? ? "1" : "0"
    ldflags = "-X main.version=#{version} -X main.buildSource=#{tap.user}"
    system "go", "build", "-mod=vendor", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"lazygit", "completion", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/lazygit -v")

    system "git", "init", "--initial-branch=main"

    s = testpath/"test.txt"
    pid = spawn(bin/"lazygit", "-l", out: s.to_s, err: [:child, :out])
    sleep 2
    assert_match "Log file does not exist. Run `lazygit --debug` first to create the log file", s.read
  ensure
    Process.kill("TERM", pid)
    Process.wait(pid)
  end
end
