defmodule Gw2Router.RoutingQueue do
  use Oban.Worker, queue: :routing, max_attempts: 2
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    IO.inspect(args)
  end
end
