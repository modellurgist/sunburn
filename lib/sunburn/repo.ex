defmodule Sunburn.Repo do
  use Ecto.Repo,
    otp_app: :sunburn,
    adapter: Ecto.Adapters.Postgres
end
