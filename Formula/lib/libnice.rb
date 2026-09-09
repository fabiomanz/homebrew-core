class Libnice < Formula
  desc "GLib ICE implementation"
  homepage "https://wiki.freedesktop.org/nice/"
  url "https://libnice.freedesktop.org/releases/libnice-0.1.24.tar.gz"
  sha256 "cfb5e8e778534f2f5b3c6f4958a1eb057c6b95c537c0f100817a537cf5d64fcc"
  license any_of: ["LGPL-2.1-or-later", "MPL-1.1"]
  compatibility_version 1
  head "https://gitlab.freedesktop.org/libnice/libnice.git", branch: "master"

  livecheck do
    url "https://libnice.freedesktop.org/"
    regex(/href=.*?libnice[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/fabiomanz/intel-bottles/releases/download/bottles"
    sha256 cellar: :any, tahoe: "8e92b1e97397bb118c72bb438c12376bfb713005dcff17d6d79c42e656751ecd"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]

  depends_on "glib"
  depends_on "gnutls"

  on_macos do
    depends_on "gettext"
  end

  def install
    system "meson", "setup", "build", "-Dgstreamer=disabled", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    # Based on https://github.com/libnice/libnice/blob/HEAD/examples/simple-example.c
    (testpath/"test.c").write <<~C
      #include <agent.h>
      int main(int argc, char *argv[]) {
        NiceAgent *agent;
        GMainLoop *gloop;
        gloop = g_main_loop_new(NULL, FALSE);
        // Create the nice agent
        agent = nice_agent_new(g_main_loop_get_context (gloop),
          NICE_COMPATIBILITY_RFC5245);
        if (agent == NULL)
          g_error("Failed to create agent");

        g_main_loop_unref(gloop);
        g_object_unref(agent);
        return 0;
      }
    C

    flags = shell_output("pkgconf --cflags --libs nice").chomp.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
