class Neovide < Formula
  desc "No Nonsense Neovim Client in Rust"
  homepage "https://neovide.dev/"
  url "https://github.com/neovide/neovide/archive/refs/tags/0.17.0.tar.gz"
  sha256 "3cd9dc6d4e3897f204528360793faf77745d7c3f142ce5d60706801f3483cbb7"
  license "MIT"
  head "https://github.com/neovide/neovide.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "7a68ea4888944885853c8d83d660a568adb6537a7b07a8f5efb86a36e8114286"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "8ea59cef9ceca355ad8e2a8c017d46a2e245c78302d003384046d3ef235e04b0"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "1524bd892611f330c5535fb43102b878cda9902f3de13aad0753ce0df05afd22"
    sha256 cellar: :any,                 arm64_linux:       "5dd8070bdbf688da267752c4209a92bb412144769749b2a591be6299eee7661b"
    sha256 cellar: :any,                 x86_64_linux:      "a9ea9b51cc910f709eb0cc88f663483a0e9b7794b8c203f00cf3cabfb9ac4dce"
  end

  depends_on "ninja" => :build
  depends_on "rust" => :build
  depends_on "neovim"

  uses_from_macos "llvm" => :build
  uses_from_macos "python" => :build

  on_macos do
    # work around https://github.com/rust-skia/rust-skia/issues/1331
    depends_on "llvm@22" => :build if DevelopmentTools.clang_build_version >= 2100
  end

  on_linux do
    depends_on "xorg-server" => :test
    depends_on "expat"
    depends_on "fontconfig"
    depends_on "freetype"
    depends_on "harfbuzz"
    depends_on "icu4c@79"
    depends_on "jpeg-turbo"
    depends_on "libpng"
    # `libxcursor` is loaded when using X11 (DISPLAY) instead of Wayland (WAYLAND_DISPLAY).
    # Once https://github.com/rust-windowing/winit/commit/aee95114db9c90eef6f4d895790552791cf41ab9
    # is in a `winit` release, check `lsof -p <neovide-pid>` to see if dependency can be removed
    depends_on "libxcursor"
    depends_on "libxkbcommon" # dynamically loaded by xkbcommon-dl
    depends_on "mesa" # dynamically loaded by glutin
    depends_on "zlib-ng-compat"
  end

  fails_with :gcc do
    cause "Skia build uses clang target option"
  end

  def install
    ENV["FORCE_SKIA_BUILD"] = "1" # avoid pre-built `skia`

    # FIXME: On macOS, `skia-bindings` crate only allows building `skia` with bundled libraries
    if OS.linux?
      ENV["SKIA_USE_SYSTEM_LIBRARIES"] = "1"
      ENV["CLANG_PATH"] = which(ENV.cc) # force bindgen to use superenv clang to find brew libraries

      # GN doesn't use CFLAGS so pass extra paths using superenv
      ENV.append_path "HOMEBREW_INCLUDE_PATHS", formula_opt_include("freetype")/"freetype2"
      ENV.append_path "HOMEBREW_INCLUDE_PATHS", formula_opt_include("harfbuzz")/"harfbuzz"
    elsif DevelopmentTools.clang_build_version >= 2100
      # Work around https://github.com/rust-skia/rust-skia/issues/1331
      ENV["CLANG_PATH"] = formula_opt_bin("llvm@22")/"clang"
    end

    system "cargo", "install", *std_cargo_args

    return unless OS.mac?

    # Use upstream's app template, as their release builds do
    prefix.install "extra/osx/Neovide.app"
    (prefix/"Neovide.app/Contents/MacOS").install bin/"neovide"
    bin.write_exec_script prefix/"Neovide.app/Contents/MacOS/neovide"
  end

  def nvim_ui_count(socket)
    Utils.safe_popen_read(
      "nvim", "--headless",
              "--server", socket,
              "--remote-expr", 'luaeval("vim.tbl_count(vim.api.nvim_list_uis())")'
    ).chomp.to_i
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/neovide --version")
    return if OS.mac? # unable to start neovide within macOS sandbox

    socket = testpath/"nvim.sock"
    nvim_cmd = ["nvim", "--headless", "-i", "NONE", "-u", "NONE", "--listen", socket]
    ohai nvim_cmd.join(" ")
    nvim_pid = spawn(*nvim_cmd)

    sleep 1 until socket.exist? && socket.socket?

    IO.pipe do |read_io, write_io|
      xvfb = formula_opt_bin("xorg-server")/"Xvfb"
      xvfb_pid = spawn(xvfb, "-displayfd", write_io.fileno.to_s, write_io => write_io)
      write_io.close
      ENV["DISPLAY"] = ":#{read_io.read.strip}"

      neovide_cmd = [bin/"neovide", "--no-fork", "--server=#{socket}"]
      ohai neovide_cmd.join(" ")
      neovide_pid = spawn(*neovide_cmd)

      sleep 1 until nvim_ui_count(socket).positive?
      system "nvim", "--server", socket, "--remote-send", ":q<CR>"

      Process.wait nvim_pid
      Process.wait neovide_pid
    ensure
      if xvfb_pid
        Process.kill "TERM", xvfb_pid
        Process.wait xvfb_pid
      end
    end
  end
end
