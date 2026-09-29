class Renovate < Formula
  desc "Automated dependency updates. Flexible so you don't need to be"
  homepage "https://github.com/renovatebot/renovate"
  url "https://registry.npmjs.org/renovate/-/renovate-44.118.0.tgz"
  sha256 "0ff44373b80db124a46b1019aeaa4444748aa8398f471dbf0a6be6ad9708ac01"
  license "AGPL-3.0-only"

  # livecheck needs to surface multiple versions for version throttling but
  # there are thousands of renovate releases on npm. The package page showing
  # versions is several MB in size (and the registry response is 10x that),
  # so curl can time out before the response finishes. This checks releases on
  # GitHub as a workaround, as it provides information on multiple versions
  # but has a much smaller size.
  livecheck do
    url :homepage
    strategy :github_releases
    throttle 10
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0381d18f4551bb8f4df5fd6e9c5b8a9f24937004986d0ec13601168110bfa2b4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "0381d18f4551bb8f4df5fd6e9c5b8a9f24937004986d0ec13601168110bfa2b4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "0381d18f4551bb8f4df5fd6e9c5b8a9f24937004986d0ec13601168110bfa2b4"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "9627c0610b453a8fefa2663da0b56d7f1e5df21bc98f75ae1d9a8d6c5b40fdc0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:      "9627c0610b453a8fefa2663da0b56d7f1e5df21bc98f75ae1d9a8d6c5b40fdc0"
  end

  depends_on "node@24"

  uses_from_macos "git", since: :monterey # needs git >= 2.33.0 (Apple Git-136)

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    # Renovate filters child env vars, so Homebrew's git shim cannot run.
    ENV.remove "PATH", HOMEBREW_SHIMS_PATH/"shared"
    system bin/"renovate", "--platform=local", "--enabled=false"
  end
end
