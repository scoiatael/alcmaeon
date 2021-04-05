defmodule Alcmaeon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    children =
      [
        # Start the Ecto repository
        # Alcmaeon.Repo,
        # Start the Telemetry supervisor
        AlcmaeonWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: Alcmaeon.PubSub},
        # Start the Endpoint (http/https)
        AlcmaeonWeb.Endpoint,
        # Start a worker by calling: Alcmaeon.Worker.start_link(arg)
        FlyioLibcluster.Region,
        {Cluster.Supervisor,
         [
           Application.get_env(:libcluster, :topologies),
           [name: FlyioLibcluster.ClusterSupervisor]
         ]}
      ] ++ maybe_script() ++ [Alcmaeon.Stage]

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

  defp maybe_script do
    if Application.get_env(:alcmaeon, :script_region) == FlyioLibcluster.Region.fly_region() do
      Logger.info("Application: starting Script as we are primary")
      [Alcmaeon.Script]
    else
      Logger.warn("Application: someone else is primary")
      []
    end
  end
end
