class Meilisearch < Formula
  desc "Ultra relevant, instant and typo-tolerant full-text search API"
  homepage "https://docs.meilisearch.com/"
  url "https://github.com/meilisearch/meilisearch/archive/refs/tags/v1.54.1.tar.gz"
  sha256 "0e7f418e9b44131880fc6d2cb7080b9c26430d32ba32261818b0eedf66c6d145"
  license "MIT"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "e9f0aa6840b74e32453b565d6d9b230bb0ab427eca975083cb7d15c29843b6d8"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "c8e2eef9d83cb42640fc6c03d637d2f17b65cccca4cae7e8aac8c10cf6658401"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c583f04531f2548ed985813f59b907e0d5d79489c3025804a4956b6bfdb24617"
    sha256 cellar: :any,                 arm64_linux:       "114fd95329079995e6711e59f0c7378b8571676be961bd541c15bb5a54a395c0"
    sha256 cellar: :any,                 x86_64_linux:      "efd66cb0a097e72a7c8a731a17c24340619e7648f070db9f1d4bfbda35375c22"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "crates/meilisearch")
  end

  service do
    run [opt_bin/"meilisearch", "--db-path", "#{var}/meilisearch/data.ms"]
    keep_alive false
    working_dir var
    log_path var/"log/meilisearch.log"
    error_log_path var/"log/meilisearch.log"
  end

  test do
    port = free_port
    spawn bin/"meilisearch", "--http-addr", "127.0.0.1:#{port}"
    output = shell_output("curl --silent --retry 5 --retry-connrefused 127.0.0.1:#{port}/version")
    assert_match version.to_s, output
  end
end
