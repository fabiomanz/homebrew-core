class Doctl < Formula
  desc "Command-line tool for DigitalOcean"
  homepage "https://docs.digitalocean.com/reference/doctl/"
  url "https://github.com/digitalocean/doctl/archive/refs/tags/v1.170.0.tar.gz"
  sha256 "55d05b823b3d124a09f9435250b84f544df0b5fe80a84c2f60798ea7f7943467"
  license "Apache-2.0"
  head "https://github.com/digitalocean/doctl.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "a12dda342aa1970e7529664320bb5a69cdbc0cf675be1f66f61a04dd76e4f6e9"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "a12dda342aa1970e7529664320bb5a69cdbc0cf675be1f66f61a04dd76e4f6e9"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "a12dda342aa1970e7529664320bb5a69cdbc0cf675be1f66f61a04dd76e4f6e9"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "3b55d4785c6d026cd6ff520a35f7455f475a890b9c90ad72bd890c4dda9cc791"
    sha256 cellar: :any,                 x86_64_linux:      "bcc697245bdaec746f2eb6b284a99a0b3de8a225d32c0e6b3ca2e346f2137017"
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
