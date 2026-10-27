class Tunnelite < Formula
  desc "Secure tunneling to local applications"
  homepage "https://tunnelite.com"
  url "https://github.com/cristipufu/tunnelite/archive/refs/tags/v1.3.1.tar.gz"
  sha256 "58effe38dc41b5b355bc06eeb1c230d28f9f78dbd5433d0e1c90634d76efbe53"
  license "MIT"
  head "https://github.com/cristipufu/tunnelite.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "b0733739b37edb345fadce0fe13fda0a006fd3010a949a35894d16103ac2e588"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "46630d02a8d181d7b8b43a667be6016e3d82dd3baec2ed317d747b9ed889ca21"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "c1fe02f8d7b44a0d138f8846a8ff36c0cf24ea3f8e01257e6da61f42465aac5f"
    sha256 cellar: :any,                 arm64_linux:       "41b466a3d51719d049d7cc5b74f56b650fe7d106bf87f5876c53e4c5305eb049"
    sha256 cellar: :any,                 x86_64_linux:      "25f13a9d343bd85220e32955d68e7db37b627ab4fb792e4db904c04786bd96be"
  end

  depends_on "dotnet"

  def install
    ENV["DOTNET_CLI_TELEMETRY_OPTOUT"] = "1"
    ENV["DOTNET_SYSTEM_GLOBALIZATION_INVARIANT"] = "1"
    # .NET's user-scoped named mutexes need a writable runtime directory on Linux.
    ENV["XDG_RUNTIME_DIR"] = buildpath

    dotnet = Formula["dotnet"]
    # Force a single MSBuild node: worker-node sockets are denied by the macOS sandbox (Homebrew/brew#23920)
    args = %W[
      --configuration Release
      --framework net#{dotnet.version.major_minor}
      --output #{libexec}
      --no-self-contained
      --use-current-runtime
      -p:PublishSingleFile=true
      -p:Version=#{version}
    ]
    system "dotnet", "publish", "src/Tunnelite.Client/Tunnelite.Client.csproj", *args

    env = { DOTNET_ROOT: "${DOTNET_ROOT:-#{dotnet.opt_libexec}}" }
    (bin/"tunnelite").write_env_script libexec/"Tunnelite.Client", env
  end

  test do
    # The sandbox denies FSEvents, so .NET's config file watcher would hang
    ENV["DOTNET_USE_POLLING_FILE_WATCHER"] = "1" if OS.mac?

    assert_match version.to_s, shell_output("#{bin}/tunnelite --version")
    shell_output("#{bin}/tunnelite ftp://localhost:1 2>&1", 1)
  end
end
