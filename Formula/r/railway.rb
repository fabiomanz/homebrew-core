class Railway < Formula
  desc "Develop and deploy code with zero configuration"
  homepage "https://railway.com/"
  url "https://github.com/railwayapp/cli/archive/refs/tags/v5.49.5.tar.gz"
  sha256 "dc8800b70b2eabced778c0ca68dcd66a460f72fc924b4bb92dc1f2ce323e8e48"
  license "MIT"
  head "https://github.com/railwayapp/cli.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "c737ce7ee4678a98831bd76424b67823191af95bb607d89c4c36a5c03a57a687"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c6993766442a96160b6305bc5541fdee2b9a6804d3d101cc92b59b19926fc8fd"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "41fbe0f565d82a127f0984eb7e02990cf5ab08901cf74ba69b2772f522ca69d4"
    sha256 cellar: :any,                 arm64_linux:   "332b0c7d0359cb747b91c966e1dbc53864b089cccdf1a2294fdaee5159f78b15"
    sha256 cellar: :any,                 x86_64_linux:  "753b1769b8125f6b4fbabe0945e9264151fa6f78837785a21fbd1376beb2ec55"
  end

  depends_on "rust" => :build

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
