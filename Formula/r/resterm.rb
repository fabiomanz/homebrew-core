class Resterm < Formula
  desc "Terminal client for .http/.rest files with HTTP, GraphQL, and gRPC support"
  homepage "https://github.com/unkn0wn-root/resterm"
  url "https://github.com/unkn0wn-root/resterm/archive/refs/tags/v1.10.1.tar.gz"
  sha256 "d6af103161f732b1370ffbcb09d883d70b2979e865ff86137346f40d92dd39cd"
  license "Apache-2.0"
  head "https://github.com/unkn0wn-root/resterm.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "1bbaf94233524d7d590455e00ced28c7dc4722b33d0021ae519551952c1303d4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "1bbaf94233524d7d590455e00ced28c7dc4722b33d0021ae519551952c1303d4"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "1bbaf94233524d7d590455e00ced28c7dc4722b33d0021ae519551952c1303d4"
    sha256 cellar: :any_skip_relocation, arm64_linux:       "03535384eb24c01962be7dc289bc7064770ff7250f8ba6e44db509bf5c85ad56"
    sha256 cellar: :any,                 x86_64_linux:      "72f9f48bff54ac6f6bb3f3ae65e7a47b10f5c48f360471488959a4589636457d"
  end

  depends_on "go" => :build

  deny_network_access!

  def fetch
    system "go", "mod", "download"
  end

  def install
    system "go", "build", *std_go_args(ldflags: :goreleaser), "./cmd/resterm"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/resterm -version")

    (testpath/"openapi.yml").write <<~YAML
      openapi: 3.0.0
      info:
        title: Test API
        version: 1.0.0
        description: A simple test API
      servers:
        - url: https://api.example.com
          description: Production server
      paths:
        /ping:
          get:
            summary: Ping endpoint
            operationId: ping
            responses:
              "200":
                description: Successful response
                content:
                  application/json:
                    schema:
                      type: object
                      properties:
                        message:
                          type: string
                          example: "pong"
      components:
        schemas:
          PingResponse:
            type: object
            properties:
              message:
                type: string
    YAML

    system bin/"resterm", "--from-openapi", testpath/"openapi.yml",
                          "--http-out",     testpath/"out.http",
                          "--openapi-base-var", "apiBase",
                          "--openapi-server-index", "0"

    assert_match "GET {{apiBase}}/ping", (testpath/"out.http").read
  end
end
