class Dcd < Formula
  desc "Auto-complete program for the D programming language"
  homepage "https://github.com/dlang-community/DCD"
  url "https://github.com/dlang-community/DCD.git",
      tag:      "v0.19.0",
      revision: "ab8d79f98ed79d4b3d39dedbf08e897f0ce63229"
  license "GPL-3.0-or-later"
  head "https://github.com/dlang-community/dcd.git", branch: "master"

  bottle do
    sha256               arm64_golden_gate: "7b9748aba068c05a7a2b6a4a57a5d4e0213292f0a086118266b4daa9f3efddc9"
    sha256               arm64_tahoe:       "91b756a897218199607f2da1fbafdf0288bcccfab8c8606d564b7bac8681c8c5"
    sha256               arm64_sequoia:     "a26d733b197b5dd44851a946ae86a476118e57816e667b090011dc2b3df6750e"
    sha256 cellar: :any, arm64_linux:       "b0d870a8e34c6958f5e733ee2c0f658db62524813c2c0aa7fbc86905be9b7aa9"
    sha256 cellar: :any, x86_64_linux:      "d5485ba1d67f0a651e6fa6a8a324efa4fc5c021f50ad575b65c4f79f42fe603e"
  end

  depends_on "ldc" => :build

  def install
    system "make", "ldc"
    bin.install "bin/dcd-client", "bin/dcd-server"
  end

  test do
    port = free_port

    # spawn a server, using a non-default port to avoid
    # clashes with pre-existing dcd-server instances
    server = spawn bin/"dcd-server", "-p", port.to_s
    # Give it generous time to load
    sleep 0.5
    # query the server from a client
    system bin/"dcd-client", "-q", "-p", port.to_s
  ensure
    Process.kill "TERM", server
    Process.wait server
  end
end
