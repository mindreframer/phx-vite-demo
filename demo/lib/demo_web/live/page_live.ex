defmodule DemoWeb.PageLive do
  use DemoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://hexdocs.pm/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No dependencies found matching \"#{query}\"")
         |> assign(results: %{}, query: query)}
    end
  end

  defp search(query) do
    for {app, desc, vsn} <- started_apps(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end

  defp started_apps() do
    [
      {:demo, 'demo', '0.1.0'},
      {:plug_cowboy, 'A Plug adapter for Cowboy', '2.4.1'},
      {:cowboy_telemetry, 'Telemetry instrumentation for Cowboy', '0.3.1'},
      {:cowboy, 'Small, fast, modern HTTP server.', '2.8.0'},
      {:ranch, 'Socket acceptor pool for TCP protocols.', '1.7.1'},
      {:cowlib, 'Support library for manipulating Web protocols.', '2.9.1'},
      {:jason, 'A blazing fast JSON parser and generator in pure Elixir.\n', '1.2.2'},
      {:telemetry_poller,
       'Periodically collect measurements and dispatch them as Telemetry events.', '0.5.1'},
      {:phoenix_live_dashboard, 'Real-time performance dashboard for Phoenix', '0.4.0'},
      {:telemetry_metrics,
       'Provides a common interface for defining metrics based on Telemetry events.\n', '0.6.0'},
      {:phoenix_live_reload, 'Provides live-reload functionality for Phoenix', '1.3.0'},
      {:file_system,
       'A file system change watcher wrapper based on [fs](https://github.com/synrc/fs)',
       '0.2.10'},
      {:phoenix_live_view, 'Rich, real-time user experiences with server-rendered HTML\n',
       '0.15.4'},
      {:phoenix_html, 'Phoenix view functions for working with HTML templates', '2.14.3'},
      {:runtime_tools, 'RUNTIME_TOOLS', '1.15'},
      {:logger, 'logger', '1.11.2'},
      {:gettext, 'Internationalization and localization through gettext', '0.18.2'},
      {:phoenix,
       'Productive. Reliable. Fast. A productive web framework that\ndoes not compromise speed or maintainability.\n',
       '1.5.7'},
      {:phoenix_pubsub, 'Distributed PubSub and Presence platform', '2.0.0'},
      {:plug, 'A specification and conveniences for composable modules between web applications',
       '1.11.0'},
      {:telemetry, 'Dynamic dispatching library for metrics and instrumentations', '0.4.2'},
      {:plug_crypto, 'Crypto-related functionality for the web', '1.2.0'},
      {:mime, 'A MIME type module for Elixir', '1.5.0'},
      {:eex, 'eex', '1.11.2'},
      {:hex, 'hex', '0.20.6'},
      {:inets, 'INETS  CXC 138 49', '7.2'},
      {:ssl, 'Erlang/OTP SSL application', '10.0'},
      {:public_key, 'Public key infrastructure', '1.8'},
      {:asn1, 'The Erlang ASN1 compiler version 5.0.13', '5.0.13'},
      {:crypto, 'CRYPTO', '4.7'},
      {:mix, 'mix', '1.11.2'},
      {:iex, 'iex', '1.11.2'},
      {:elixir, 'elixir', '1.11.2'},
      {:compiler, 'ERTS  CXC 138 10', '7.6.1'},
      {:stdlib, 'ERTS  CXC 138 10', '3.13'},
      {:kernel, 'ERTS  CXC 138 10', '7.0'}
    ]
  end
end
