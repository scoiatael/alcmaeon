defmodule Alcmaeon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Alcmaeon.Repo,
      # Start the Telemetry supervisor
      AlcmaeonWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Alcmaeon.PubSub},
      # Start the Endpoint (http/https)
      AlcmaeonWeb.Endpoint,
      # Start a worker by calling: Alcmaeon.Worker.start_link(arg)
      Alcmaeon.Script
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Alcmaeon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AlcmaeonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
