class Railway < Formula
  desc "Develop and deploy code with zero configuration"
  homepage "https://railway.com/"
  url "https://github.com/railwayapp/cli/archive/refs/tags/v5.63.0.tar.gz"
  sha256 "997cc8fd51090f1f710c0995931dc33ef75ab5014bea652d64796bce3b433cd9"
  license "MIT"
  head "https://github.com/railwayapp/cli.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "83183a82833ea55fbec2bf77e945f8848dc4e9fdfd91b0aff60b287b4739fb1c"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "748318c8f6a7626b8f10a78cf0695170d0177be9ecffe84c6f64c2ebfd585336"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "76c74a502acb514b3890f3992424117830c6808623a7ec6fff9d6b3eef506fb5"
    sha256 cellar: :any,                 arm64_linux:       "d3e1336994a458b5ed373b533883d657b2e8d0753066100488f683b3d29302d4"
    sha256 cellar: :any,                 x86_64_linux:      "63a8e0d7f938eb084cf3ab8b02e5175594fc522c75e9ecb21df19d17e4042598"
  end

  depends_on "rust" => :build

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    system "cargo", "install", *std_cargo_args

    generate_completions_from_executable(bin/"railway", "completion")
  end

  test do
    output = shell_output("#{bin}/railway init 2>&1", 1).chomp
    assert_match "Unauthorized. Please login with `railway login`", output

    assert_equal "railway #{version}", shell_output("#{bin}/railway --version").strip
  end
end
