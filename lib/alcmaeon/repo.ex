defmodule Alcmaeon.Repo do
  use Ecto.Repo,
    otp_app: :alcmaeon,
    adapter: Ecto.Adapters.Postgres
end
