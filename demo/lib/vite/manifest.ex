defmodule Vite do
  defmodule PhxManifestReader do
    @moduledoc """
    Finding proper path for `cache_manifest.json` in releases is a non-trivial operation,
    so we keep this logic in a dedicated module with some logic copied verbatim from
    a Phoenix private function from Phoenix.Endpoint.Supervisor
    """

    require Logger

    @endpoint DemoWeb.Endpoint
    @cache_key {:vite, "cache_manifest"}

    def read() do
      case :persistent_term.get(@cache_key, nil) do
        nil ->
          res = read(current_env())
          :persistent_term.put(@cache_key, res)
          res
        res ->
          res
      end
    end

    @doc """
    # copy from
    - `defp cache_static_manifest(endpoint)`
    - https://github.com/phoenixframework/phoenix/blob/a206768ff4d02585cda81a2413e922e1dc19d556/lib/phoenix/endpoint/supervisor.ex#L411
    """
    def read(:prod) do
      if inner = @endpoint.config(:cache_static_manifest) do
        {app, inner} =
          case inner do
            {_, _} = inner -> inner
            inner when is_binary(inner) -> {@endpoint.config(:otp_app), inner}
            _ -> raise ArgumentError, ":cache_static_manifest must be a binary or a tuple"
          end

        outer = Application.app_dir(app, inner)

        if File.exists?(outer) do
          outer |> File.read!() |> Phoenix.json_library().decode!()
        else
          Logger.error "Could not find static manifest at #{inspect outer}. " <>
                       "Run \"mix phx.digest\" after building your static files " <>
                       "or remove the configuration from \"config/prod.exs\"."
        end
      else
        %{}
      end
    end

    def read(_) do
      File.read!(manifest_path()) |> Jason.decode!()
    end

    def manifest_path() do
      @endpoint.config(:cache_static_manifest) || "priv/static/cache_manifest.json"
    end

    def current_env() do
      Application.get_env(:demo, :environment, :dev)
    end
  end

  defmodule Manifest do
    @moduledoc """
    Basic and incomplete parser for Vite.js manifests
    See for more details:
    - https://vitejs.dev/guide/backend-integration.html
    - https://github.com/vitejs/vite/blob/main/packages/vite/src/node/plugins/manifest.ts

    Sample content for the manifest:
    `
    {
      "src/main.tsx": {
        "file": "assets/main.046c02cc.js",
        "src": "src/main.tsx",
        "isEntry": true,
        "imports": [
          "_vendor.ef08aed3.js"
        ],
        "css": "assets/main.54797e95.css"
      },
      "_vendor.ef08aed3.js": {
        "file": "assets/vendor.ef08aed3.js"
      }
    }
    `
    """
    # specified in vite.config.js in build.rollupOptions.input
    @main_file "src/main.tsx"

    @spec read() :: map()
    def read() do
      PhxManifestReader.read()
    end

    @spec main_js() :: binary()
    def main_js() do
      get_file(@main_file)
    end

    @spec main_css() :: binary()
    def main_css() do
      get_css(@main_file)
    end

    @spec vendor_js() :: binary()
    def vendor_js() do
      get_imports(@main_file) |> Enum.at(0)
    end

    @spec get_file(binary()) :: binary()
    def get_file(file) do
      read() |> get_in([file, "file"]) |> prepend_slash()
    end

    @spec get_css(binary()) :: binary()
    def get_css(file) do
      read() |> get_in([file, "css"]) |> prepend_slash()
    end

    @spec get_imports(binary()) :: list(binary())
    def get_imports(file) do
      read() |> get_in([file, "imports"]) |> Enum.map(&get_file/1)
    end

    @spec prepend_slash(binary()) :: binary()
    defp prepend_slash(file) do
      "/" <> file
    end
  end
end
