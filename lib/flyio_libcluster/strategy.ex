defmodule FlyioLibcluster.Strategy do
  @moduledoc """
  Assumes you have nodes deployed on https://fly.io. Private network has to be enabled in `fly.toml` with
  ```
  [experimental]
  private_network = true
  ```
  and your release should listen on fly-assigned IPv6 address - configurable by
  1) running `mix release.init`,
  2) changing `rel/env.sh.eex` to contain:
  ```
  export RELEASE_DISTRIBUTION=name
  export RELEASE_NODE="<%= @release.name %>@$(grep fly-local-6pn /etc/hosts | cut -f 1)"
  ```
  3) adding to `rel/vm.args.eex`:
  ```
  -proto_dist inet6_tcp
  ```

  If your setup matches those assumptions, this strategy will periodically poll DNS and connect
  all nodes it finds.
  ## Options
  * `poll_interval` - How often to poll in milliseconds (optional; default: 5_000)
  * `query` - DNS query to use (optional; default: "<fly app name>.internal")
  * `node_basename` - The short name of the nodes you wish to connect to (optional; default: release name)
  ## Usage
      config :libcluster,
        topologies: [
          fly6pn: [
            strategy: #{__MODULE__},
            config: []]]
  """

  alias Cluster.Strategy.{State, DNSPoll}

  def start_link([%State{config: config} = state]),
    do: GenServer.start_link(DNSPoll, [%State{state | config: with_defaults(config)}])

  defp with_defaults(config) do
    [
      query: "#{app_name()}.internal",
      node_basename: release_name()
    ]
    |> Keyword.merge(config)
  end

  defp app_name(), do: System.fetch_env!("FLY_APP_NAME")
  defp release_name(), do: System.fetch_env!("RELEASE_NAME")
end
