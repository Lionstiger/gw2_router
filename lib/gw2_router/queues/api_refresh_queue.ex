defmodule Gw2Router.APIRefreshQueue do
  use Oban.Worker, queue: :data_refresh, max_attempts: 2
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    IO.inspect(args)
  end
end
