defmodule Gw2Router.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Gw2RouterWeb.Telemetry,
      Gw2Router.Repo,
      {DNSCluster, query: Application.get_env(:gw2_router, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Gw2Router.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Gw2Router.Finch},
      # Start a worker by calling: Gw2Router.Worker.start_link(arg)
      # {Gw2Router.Worker, arg},
      # Start to serve requests, typically the last entry
      Gw2RouterWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gw2Router.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Gw2RouterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
