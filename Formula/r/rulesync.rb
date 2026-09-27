class Rulesync < Formula
  desc "Unified AI rules management CLI tool"
  homepage "https://github.com/dyoshikawa/rulesync"
  url "https://registry.npmjs.org/rulesync/-/rulesync-20.0.0.tgz"
  sha256 "bee9aed90ba5c1226d9c1eb2cef0d1b24287535bbea8360c150df9689a6b05a5"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "a5229b381dbc8558ddd5898257ee4e3ad03c77d60cbd4e6024eadf1a86fda308"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "a5229b381dbc8558ddd5898257ee4e3ad03c77d60cbd4e6024eadf1a86fda308"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "a5229b381dbc8558ddd5898257ee4e3ad03c77d60cbd4e6024eadf1a86fda308"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "d5cc48cc4f03407f9f311d50159a4e99973af9a4f3a1698f3ae4d3fb3d89570c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "d5cc48cc4f03407f9f311d50159a4e99973af9a4f3a1698f3ae4d3fb3d89570c"
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
