defmodule Gw2Router.WaypointChecker do
  use GenServer

  alias Gw2Router.Waypoint

  # Client API

  @doc """
  Starts the ElementCache GenServer.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Searches the cached elements by a given query string.
  The search is case-insensitive and checks against the `name` field.
  """
  def search(query) do
    GenServer.call(__MODULE__, {:search, query})
  end

  # GenServer Callbacks

  @impl true
  def init(:ok) do
    all_wp = Waypoint.get_all_waypoints()
    IO.inspect(List.first(all_wp))
    {:ok, %{waypoints: all_wp}}
  end

  @impl true
  def handle_call({:search, query}, _from, state) do
    wp_chatlinks = String.split(query, ~r/\s+/, trim: true)

    results =
      Enum.map(wp_chatlinks, fn search_wp ->
        Enum.find(state.waypoints, fn saved_wp ->
          search_wp == saved_wp.chatlink
        end)
      end)
      |> Enum.reject(&is_nil/1)

    # results =
    #   Enum.filter(state.waypoints, fn wp ->
    #     Enum.any?(wp_chatlinks, fn search_wp ->
    #       search_wp == wp.chatlink
    #     end)
    #   end)

    {:reply, results, state}
  end

  @impl true
  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, _state) do
    :ok
  end
end
