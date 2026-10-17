class Rulesync < Formula
  desc "Unified AI rules management CLI tool"
  homepage "https://github.com/dyoshikawa/rulesync"
  url "https://registry.npmjs.org/rulesync/-/rulesync-36.0.1.tgz"
  sha256 "ae6c76625d356085e48934af5eed8de87aa7eb71b237d45c6b52184461084163"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "3e0a3caf91e6a0a2c47ec208ebd1edd4a53023dcef5926853946655d9e5da851"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "3e0a3caf91e6a0a2c47ec208ebd1edd4a53023dcef5926853946655d9e5da851"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "3e0a3caf91e6a0a2c47ec208ebd1edd4a53023dcef5926853946655d9e5da851"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "367d01ef207626b536a8e828da98bd4621e5343bd264e8974f54ac5638bd251a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "367d01ef207626b536a8e828da98bd4621e5343bd264e8974f54ac5638bd251a"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rulesync --version")

    output = shell_output("#{bin}/rulesync init")
    assert_match "rulesync initialized successfully", output
    assert_match "Project overview and general development guidelines", (testpath/".rulesync/rules/overview.md").read
  end
end
