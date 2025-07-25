defmodule Gw2Router.Repo do
  use Ecto.Repo,
    otp_app: :gw2_router,
    adapter: Ecto.Adapters.Postgres
end
