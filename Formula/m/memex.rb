class Memex < Formula
  desc "Index and search local agent conversation history"
  homepage "https://github.com/nicosuave/memex"
  url "https://github.com/nicosuave/memex/archive/refs/tags/v0.27.2.tar.gz"
  sha256 "95d5fdb4ae58724e0112419ebba19032d16c1e3e31474b4de2993a55bfb53d2a"
  license "MIT"
  head "https://github.com/nicosuave/memex.git", branch: "main"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "66ee7f26634194e53b4685994d8c309822479df323f1dfa41a84f8ca1f028091"
    sha256 cellar: :any, arm64_tahoe:       "2c7cfb2eb0a969df34856b6c088af4dfbd0003f860fb696cd5df44ca0606f08d"
    sha256 cellar: :any, arm64_sequoia:     "e5fdc201253302692a3bfbf2c1e44f75cc3ad3c177d0cb07029dc7125e551f5a"
    sha256 cellar: :any, arm64_linux:       "1a714ecc28843d46ce9582ac9c4e0eb6bcd99fd9a31b1137d5d92b514e082e8d"
    sha256 cellar: :any, x86_64_linux:      "d9f430dd573321791ead954b015becb1c62b844d7c9b1eeff36df78997b775c0"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "onnxruntime"

  uses_from_macos "sqlite"

  on_linux do
    depends_on "openssl@4"
  end

  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    ENV["ORT_LIB_PATH"] = formula_opt_lib("onnxruntime")
    ENV["ORT_PREFER_DYNAMIC_LINK"] = "1"
    ENV["LIBSQLITE3_SYS_USE_PKG_CONFIG"] = "1"
    system "cargo", "install", *std_cargo_args, "--no-default-features"
  end

  service do
    run [opt_bin/"memex", "daemon", "run"]
    keep_alive true
    log_path var/"log/memex.log"
    error_log_path var/"log/memex.log"
  end

  test do
    source = testpath/"claude"
    source.mkpath
    (source/"brew-session.jsonl").write <<~JSONL
      {"type":"user","uuid":"brew-user","sessionId":"brew-session","timestamp":"2026-01-01T00:00:00Z","cwd":"#{testpath}","message":{"role":"user","content":"Find the homebrewneedle conversation."}}
      {"type":"assistant","uuid":"brew-assistant","sessionId":"brew-session","timestamp":"2026-01-01T00:00:01Z","cwd":"#{testpath}","message":{"role":"assistant","content":[{"type":"text","text":"The homebrewneedle conversation was found."}]}}
    JSONL
    root = testpath/"index"
    root.mkpath
    (root/"config.toml").write "auto_index_on_search = false\n"
    system bin/"memex", "index", "--only-source", "claude", "--claude-path", source,
                       "--no-embeddings", "--root", root
    output = shell_output("#{bin}/memex search homebrewneedle " \
                          "--root #{root} --machine local --mode lexical --full")
    results = output.lines.map { |line| JSON.parse(line) }
    assert_equal 2, results.length
    assert_equal ["brew-session"], results.map { |result| result.fetch("session_id") }.uniq
    results.each do |result|
      assert_match "homebrewneedle", result.fetch("text")
    end
  end
end
