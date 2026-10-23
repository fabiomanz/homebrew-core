class GitPagesCli < Formula
  desc "Tool for publishing a site to a git-pages server"
  homepage "https://codeberg.org/git-pages/git-pages-cli"
  url "https://codeberg.org/git-pages/git-pages-cli/releases/download/v1.12.0/git-pages-cli-src.zip"
  sha256 "a1e9d7175e44debcda02c76b44964644ebbf85a232b3158875b87d605dd7d54b"
  license "0BSD"
  head "https://codeberg.org/git-pages/git-pages-cli.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "c2636ee1da3ecae786b523f9645b754128e9086fb7cbd0f35f4470c5abd50d6c"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c2636ee1da3ecae786b523f9645b754128e9086fb7cbd0f35f4470c5abd50d6c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c2636ee1da3ecae786b523f9645b754128e9086fb7cbd0f35f4470c5abd50d6c"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "192b8c39292ffb46f03aaa0eee7916567a769d525bf0d1976315b5708d70c7f9"
    sha256 cellar: :any,                 x86_64_linux:      "e7a855da6d9f3a6cd8cd823190455376191b207882d02b56e11dfb22bd4d6662"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: "-X main.versionOverride=#{version}")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/git-pages-cli --version")

    output = shell_output("#{bin}/git-pages-cli https://example.org --challenge 2>&1")
    assert_match "_git-pages-challenge.example.org", output
  end
end
