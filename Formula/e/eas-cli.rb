class EasCli < Formula
  desc "Command-line tool for working with Expo Application Services"
  homepage "https://docs.expo.dev/eas/"
  url "https://registry.npmjs.org/eas-cli/-/eas-cli-24.1.2.tgz"
  sha256 "edfccfe3501541019d5180a8dad2580872e23f06d96af7cfc10663701eb50d0a"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "11325c1e6e2fa031275545c050cdfed1c755a13b93c2203ebdc20b4de180bb1e"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/eas --version")
    assert_match "Run this command inside a project directory",
                 shell_output("#{bin}/eas diagnostics 2>&1", 1)
  end
end
