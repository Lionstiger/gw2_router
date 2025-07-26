defmodule Gw2Router.APIRefreshQueue do
  alias Gw2Router.Waypoint
  use Oban.Worker, queue: :data_refresh, max_attempts: 1

  require Logger

  @endpoint "https://api.guildwars2.com/v2/continents/1/floors?ids=all"
  # @endpoint "https://api.guildwars2.com/v2/continents/"

  @impl Oban.Worker
  def perform(%Oban.Job{args: _args}) do
    Phoenix.PubSub.broadcast(Gw2Router.PubSub, "admin_page", {:job_started})

    with {wp_count, _} <- get_gw2_api_data() do
      Phoenix.PubSub.broadcast(Gw2Router.PubSub, "admin_page", {:job_done, wp_count})
      :ok
    else
      {:error, reason} ->
        Phoenix.PubSub.broadcast(Gw2Router.PubSub, "admin_page", {:job_failed})
        {:error, "DB Error"}
    end
  end

  defp get_gw2_api_data() do
    with {:ok, %Req.Response{body: body}} <- Req.get(@endpoint) do
      full_wp_changeset = Gw2Router.Waypoint.build_insert_list(body)
      # File.write("test2.json", Jason.encode!(full_wp_changeset))
      # IO.inspect(full_wp_changeset)

      Gw2Router.Repo.insert_all(Gw2Router.Waypoint, full_wp_changeset,
        on_conflict: {:replace_all_except, [:id]},
        conflict_target: :poi_id
      )
    end
  end
end
