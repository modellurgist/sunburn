defmodule Sunburn.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SunburnWeb.Telemetry,
      Sunburn.Repo,
      {DNSCluster, query: Application.get_env(:sunburn, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Sunburn.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Sunburn.Finch},
      # Start a worker by calling: Sunburn.Worker.start_link(arg)
      # {Sunburn.Worker, arg},
      # Start to serve requests, typically the last entry
      SunburnWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sunburn.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SunburnWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end