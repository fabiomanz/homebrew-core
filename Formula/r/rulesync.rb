class Rulesync < Formula
  desc "Unified AI rules management CLI tool"
  homepage "https://github.com/dyoshikawa/rulesync"
  url "https://registry.npmjs.org/rulesync/-/rulesync-30.0.0.tgz"
  sha256 "a946d690fc790ded61d8c90cd006eeea027854d038a9beb28ac661f6d633511e"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "3fc6b36b5b2993d8f23b60d7f0e71d711c3f87e25eea9981c9f2148c5bd683d9"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "3fc6b36b5b2993d8f23b60d7f0e71d711c3f87e25eea9981c9f2148c5bd683d9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "3fc6b36b5b2993d8f23b60d7f0e71d711c3f87e25eea9981c9f2148c5bd683d9"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "41b15f5d0270a3b1875f0b202fc36690086a00b86fe59843c375be3998980156"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "41b15f5d0270a3b1875f0b202fc36690086a00b86fe59843c375be3998980156"
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
