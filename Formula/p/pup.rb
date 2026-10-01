class Pup < Formula
  desc "CLI companion with 200+ commands across 33+ Datadog products"
  homepage "https://www.datadoghq.com"
  url "https://github.com/DataDog/pup/releases/download/v1.23.5/pup_1.23.5_source.tar.gz"
  sha256 "a0ef893492926d3e4c2ef33d57f0c09599b13f4f03aca6fe772de521413abe41"
  license "Apache-2.0"
  head "https://github.com/DataDog/pup.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c9f00414a00f4ece7f50d3404ec882294602205f132e94212c3db5640f681708"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "2d4b268deba06b7fa6bdab7ddf92964e4af9d842b5b07f7a38112567c0cc09dc"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "ead5c424c1800c592b32f184da53a4815d6bb4d4bd26888f84923e13955d5d07"
    sha256 cellar: :any,                 arm64_linux:       "985695e17e4d723ad0e9644776f955f15513ade0304f7b05c9b79a1e8105e493"
    sha256 cellar: :any,                 x86_64_linux:      "65f13152c922676b3934a14d195e6d3672d4b8b8d349294d5fb1066325887cb1"
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
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"pup", "completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pup --version")
    assert_match "Use pup CLI or generate code", shell_output("#{bin}/pup skills list")
  end
end
