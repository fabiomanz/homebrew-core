class Doctl < Formula
  desc "Command-line tool for DigitalOcean"
  homepage "https://docs.digitalocean.com/reference/doctl/"
  url "https://github.com/digitalocean/doctl/archive/refs/tags/v1.184.0.tar.gz"
  sha256 "706b90f5637f12cd8e4463ef398149f709ed668fc707d3d9b1754c76e9e0a27d"
  license "Apache-2.0"
  head "https://github.com/digitalocean/doctl.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "80289f49b5f3e8dfc8e35970313c9cf967d058e7973bb901f28bb6b21394ecf5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "80289f49b5f3e8dfc8e35970313c9cf967d058e7973bb901f28bb6b21394ecf5"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "80289f49b5f3e8dfc8e35970313c9cf967d058e7973bb901f28bb6b21394ecf5"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "cbf45e373316a3b8ad6c261147cca3ea075d35fd1a2799c613dd03fa701209b4"
    sha256 cellar: :any,                 x86_64_linux:      "37a15929018f998b2207add7ba60503c9379b04de607a5717acd755e33086155"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/digitalocean/doctl.Major=#{version.major}
      -X github.com/digitalocean/doctl.Minor=#{version.minor}
      -X github.com/digitalocean/doctl.Patch=#{version.patch}
      -X github.com/digitalocean/doctl.Label=release
    ]

    system "go", "build", *std_go_args(ldflags:), "./cmd/doctl"

    generate_completions_from_executable(bin/"doctl", shell_parameter_format: :cobra)
  end

  test do
    assert_match "doctl version #{version}-release", shell_output("#{bin}/doctl version")
  end
end
