class RattlerIndex < Formula
  desc "Index conda channels using rattler"
  homepage "https://github.com/conda/rattler"
  url "https://github.com/conda/rattler/archive/refs/tags/rattler_index-v0.34.3.tar.gz"
  sha256 "bf3f43c4d5f3d91d6f0fe550e4e42924f37a0dcd15e918c0aab29d3111b2cfe5"
  license "BSD-3-Clause"
  head "https://github.com/conda/rattler.git", branch: "main"

  livecheck do
    url :stable
    regex(/^rattler_index-v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "e5909137f9c96680dcb0a11155438735f41b6b712b188065f6335bc8f88a42ae"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "36b288b579d95662d33d5fc88b57e255d21fda9b1d393424bb2d83d4aa1648a0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "01aaa59a5b2138e0ec538d699c427d32a77c5690d32b98fc35e457a60710c390"
    sha256 cellar: :any,                 arm64_linux:       "4640902ae47bca1fbf1217686fd14d10e302a64fcdfc2a1d1e7c2921d29d18aa"
    sha256 cellar: :any,                 x86_64_linux:      "a97bc2388208a8525eff3935c8a636c27df03550ab42cb1897e9929945c230af"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build

  on_linux do
    depends_on "openssl@4"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@4") if OS.linux?
    features = %w[native-tls s3]
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "crates/rattler_index", features:)
  end

  test do
    assert_equal "rattler-index #{version}", shell_output("#{bin}/rattler-index --version").strip

    system bin/"rattler-index", "fs", "."
    assert_path_exists testpath/"noarch/repodata.json"
  end
end
