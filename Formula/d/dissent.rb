class Dissent < Formula
  desc "GTK4 Discord client in Go"
  homepage "https://github.com/diamondburned/dissent"
  url "https://github.com/diamondburned/dissent/archive/refs/tags/v0.0.38.tar.gz"
  sha256 "067dcfcca43d879db8fce1014943dd62b747f04538196296f8a2eb1c23a67872"
  license "GPL-3.0-or-later"
  head "https://github.com/diamondburned/dissent.git", branch: "main"

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "696a272ba510b74b58907a24d5ca605ff272444cc4ebac5e3175950dd4ebd68a"
    sha256 cellar: :any, arm64_tahoe:       "0a5784b1de680617474c644e60269395a083dccd82a062e681e599a677f10eaf"
    sha256 cellar: :any, arm64_sequoia:     "64c623b1d74e36c9d01f03eaf8d5bf812564863d54c0d1ed0b6ac318ccd85605"
    sha256 cellar: :any, arm64_linux:       "f2ac36f8fd98fde6e46181088c87a694e815a4379aeedf9dd4bb68af0bbdf57b"
    sha256 cellar: :any, x86_64_linux:      "593439589d7fa013c45fbe65018d2976551790ade8a848381525bc918ee09d3f"
  end

  depends_on "go" => :build
  depends_on "pkgconf" => :build

  depends_on "cairo"
  depends_on "gdk-pixbuf"
  depends_on "glib"
  depends_on "gobject-introspection"
  depends_on "graphene"
  depends_on "gtk4"
  depends_on "gtksourceview5"
  depends_on "libadwaita"
  depends_on "libcanberra"
  depends_on "libspelling"
  depends_on "pango"
  depends_on "pcre2"

  on_macos do
    depends_on "gettext"
    depends_on "harfbuzz"
  end

  on_linux do
    depends_on "xorg-server" => :test
  end

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    # Workaround to avoid patchelf corruption when cgo is required
    if OS.linux? && Hardware::CPU.arm64?
      ENV["CGO_ENABLED"] = "1"
      ENV["GO_EXTLINK_ENABLED"] = "1"
      ENV.append "GOFLAGS", "-buildmode=pie"
    end

    system "go", "build", *std_go_args
  end

  test do
    # dissent is a GUI application
    cmd = "#{bin}/dissent --help"

    pid = nil
    if OS.linux?
      IO.pipe do |read_io, write_io|
        pid = spawn(formula_opt_bin("xorg-server")/"Xvfb", "-displayfd", write_io.fileno.to_s, write_io => write_io)
        write_io.close
        ENV["DISPLAY"] = ":#{read_io.read.strip}"
      end
    end

    assert_match "Show all help options", shell_output(cmd)
  ensure
    if pid
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
