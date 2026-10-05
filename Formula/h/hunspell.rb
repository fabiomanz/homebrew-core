class Hunspell < Formula
  desc "Spell checker and morphological analyzer"
  homepage "https://hunspell.github.io"
  url "https://github.com/hunspell/hunspell/releases/download/v1.7.5/hunspell-1.7.5.tar.gz"
  sha256 "2e559f0c2a592ba48e421477f58e9bf7e01062277a4a7821afb52fc9401010ae"
  license any_of: ["MPL-1.1", "GPL-2.0-or-later", "LGPL-2.1-or-later"]

  bottle do
    root_url "https://github.com/fabiomanz/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, tahoe: "63ef4725d5bdd95041b1e6d445847439bd16d37a33896c09bda984a1aa1489e6"
  end

  depends_on "gettext" => :build
  depends_on "readline"

  uses_from_macos "ncurses"

  on_macos do
    depends_on "coreutils" => :build # for timeout in gh646.test
    depends_on "gettext"
  end

  conflicts_with "freeling", because: "both install 'analyze' binary"

  skip_clean "share/hunspell"

  def install
    system "./configure", "--disable-silent-rules",
                          "--with-ui",
                          "--with-readline",
                          *std_configure_args
    system "make"
    system "make", "check"
    system "make", "install"

    # Find dictionaries installed by other formulae
    share.install_symlink HOMEBREW_PREFIX/"share/hunspell"
  end

  def caveats
    <<~EOS
      Dictionary files (*.aff and *.dic) should be placed in
      ~/Library/Spelling/ or /Library/Spelling/.  Homebrew itself
      provides no dictionaries for Hunspell, but you can download
      compatible dictionaries from other sources, such as
      https://cgit.freedesktop.org/libreoffice/dictionaries/tree/ .
    EOS
  end

  test do
    system bin/"hunspell", "--help"
  end
end
