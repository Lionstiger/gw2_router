defmodule Gw2Router.RoutingQueue do
  alias Ecto.Changeset
  alias Gw2Router.Waypoint
  import Ecto.Changeset
  use Oban.Worker, queue: :routing, max_attempts: 2
  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    page_id = args["page_id"]
    Phoenix.PubSub.broadcast(Gw2Router.PubSub, "route_#{page_id}", {:job_started})

    # IO.inspect(args)

    wp_list = args["wp_list"]
    level = args["level"]

    new_list =
      Enum.map(wp_list, fn raw_wp ->
        %Waypoint{}
        |> Waypoint.changeset(raw_wp)
        |> case do
          %{valid?: true} = changeset -> apply_changes(changeset)
          changeset -> {:error, changeset}
        end
      end)
      |> optimize_route()

    Phoenix.PubSub.broadcast(
      Gw2Router.PubSub,
      "route_#{page_id}",
      {:job_done, %{new_list: new_list, level: String.to_integer(level)}}
    )

    :ok
  end

  def optimize_route(wp_list) when is_list(wp_list) and length(wp_list) <= 7 do
    # Here we just bruteforce it
    if length(wp_list) <= 1 do
      wp_list
    else
      {_, shortest_path} =
        wp_list
        |> ListUtils.permutations()
        |> Enum.map(fn path -> {total_distance(path), path} end)
        |> Enum.min_by(fn {distance, _path} -> distance end)

      # |> IO.inspect()

      # |> IO.inspect()

      shortest_path
    end
  end

  def optimize_route(wp_list) when is_list(wp_list) and length(wp_list) > 7 do
    # TODO do heuristics here
    wp_list
  end

  def total_distance(wp_list) do
    wp_list
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(0.0, fn [wp1, wp2], acc ->
      acc + Waypoint.distance(wp1, wp2)
    end)
  end
end
