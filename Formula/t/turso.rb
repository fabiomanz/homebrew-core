class Turso < Formula
  desc "Interactive SQL shell for Turso"
  homepage "https://github.com/tursodatabase/turso"
  url "https://github.com/tursodatabase/turso/archive/refs/tags/v0.8.0.tar.gz"
  sha256 "51f09329c327aca24dc8ca9d4376a4ec9363606950c327db3636585c3c81586e"
  license "MIT"
  head "https://github.com/tursodatabase/turso.git", branch: "main"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "0cd51b388e19ca755f3487fc3a0fe1a73be8dec73532df329ae01aedf7304f09"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "69bd9b58f2e7126abcdceceee638d9d2a42349b85d2c4e6f9833a1d8d358f97c"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "e5e30f53259595e550b802a2ee7ad4e9280400fd21f1b07ad9afe9d25dcb96ab"
    sha256 cellar: :any,                 arm64_linux:       "6cae0f46717beb39d920130e9f8c9039cb0e2e695a0b8b79402e2cf9d184c1fd"
    sha256 cellar: :any,                 x86_64_linux:      "ed8a309c77824aa5bec95c253b840e21a097b814d9d8be4014091eff4ade8002"
  end

  depends_on "rust" => :build
  uses_from_macos "sqlite" => :test

  def install
    system "cargo", "install", *std_cargo_args(path: "cli")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tursodb --version")

    data = %w[Bob 14 Sue 12 Tim 13]
    create = "create table students (name text, age integer);\n"
    data.each_slice(2) do |n, a|
      create << "insert into students (name, age) values ('#{n}', '#{a}');\n"
    end
    pipe_output("sqlite3 school.sqlite", create, 0)

    begin
      output_log = testpath/"output.log"
      if OS.mac?
        pid = spawn bin/"tursodb", "school.sqlite", [:out, :err] => output_log.to_s
      else
        require "pty"
        r, _w, pid = PTY.spawn bin/"tursodb", "school.sqlite", [:out, :err] => output_log.to_s
        r.winsize = [80, 43]
      end
      sleep 2
      assert_match "\".help\" for usage hints.", output_log.read
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
