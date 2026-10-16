class Talosctl < Formula
  desc "CLI for out-of-band management of Kubernetes nodes created by Talos"
  homepage "https://www.talos.dev/"
  url "https://github.com/siderolabs/talos/archive/refs/tags/v1.14.3.tar.gz"
  sha256 "2488496631b4428ae06f4575f9f3ac58324aee1ce50dd44c80b1a7eae26f93be"
  license "MPL-2.0"
  head "https://github.com/siderolabs/talos.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "726557d3301c7de9e7c1f09f8f8d330ca41ea1f010dfe98ed4891a323f92ef22"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "2804d678107bc64dc75809a3c61c8ece56527bf1db555e20972a384a3ce1cbf0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "e5cf0eaee616704f6fed1afddb4481bc8a57fb251145490a1f0316f6d9a3f364"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "2bc6906619df9f0ee2c98f3be0be6535b3135f7bda0ed61a774d6d2c33151668"
    sha256 cellar: :any,                 x86_64_linux:      "00374e466ef89923af1d7a529ce545a67db0b76cb8828631d86748f449bb01b7"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    ldflags = %W[
      -X github.com/siderolabs/talos/pkg/machinery/version.Tag=#{version}
      -X github.com/siderolabs/talos/pkg/machinery/version.Built=#{time.iso8601}

    ]
    system "go", "build", *std_go_args(ldflags:), "./cmd/talosctl"

    generate_completions_from_executable(bin/"talosctl", shell_parameter_format: :cobra)
  end

  test do
    # version check also failed with `failed to determine endpoints` for server config
    assert_match version.to_s, shell_output("#{bin}/talosctl version 2>&1", 1)

    output = shell_output("#{bin}/talosctl list 2>&1", 1)
    assert_match "failed to determine endpoints", output
  end
end
