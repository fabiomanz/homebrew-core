class Railway < Formula
  desc "Develop and deploy code with zero configuration"
  homepage "https://railway.com/"
  url "https://github.com/railwayapp/cli/archive/refs/tags/v5.49.3.tar.gz"
  sha256 "c8b2ceb020bbad2b8b595f1d1e27e8296ae1743b754ca8c83c3b612c8cb9d523"
  license "MIT"
  head "https://github.com/railwayapp/cli.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "5337367229c24287a0edcd860680968338f595cc0c165a99aa5a6fa2f98f74a2"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9b9ba5d71493edd5b6feac0b354092963bb23a113b518afff49276a93dcfd8e4"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "ead99548dbed4d79941fb1ad610e7d08df72ddb654573e23a3555d68972a88a7"
    sha256 cellar: :any,                 arm64_linux:   "c5f454df978bb9723101a2ddab0d08748b566dbce40974ae288588fa44e840c5"
    sha256 cellar: :any,                 x86_64_linux:  "9c8e7151e6f7b2e1dfa325c63af891c6f1343a951a929eaebac61fd84559e76d"
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
