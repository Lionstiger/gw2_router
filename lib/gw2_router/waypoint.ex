defmodule Gw2Router.Waypoint do
  alias Gw2Router.Waypoint
  alias Gw2Router.Repo
  use Ecto.Schema
  import Ecto.Changeset

  schema "waypoints" do
    field :name, :string
    field :x, :float
    field :y, :float
    field :floor, :integer
    field :poi_id, :integer
    field :chatlink, :string

    # timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(waypoint, attrs) do
    waypoint
    |> cast(attrs, [:name, :floor, :x, :y, :poi_id, :chatlink])
    |> validate_required([:name, :floor, :x, :y, :poi_id, :chatlink])
    |> unique_constraint(:poi_id)
  end

  def get_all_waypoints() do
    Repo.all(Waypoint)
  end

  def copy_buffer(wp_list) do
    wp_list
    |> Enum.with_index(1)
    |> Enum.map(fn {wp, index} -> "#{index}: #{wp.chatlink}" end)
    |> Enum.join("\n")
  end

  def calculate_full_route_cost(wp_list, level, guild_buff)
      when is_list(wp_list) and is_integer(level) do
    new_cost =
      wp_list
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [p1, p2] ->
        if p1 == p2 do
          0.0
        else
          calculate_travel_cost(p1, p2, level, guild_buff)
        end
      end)
      |> Enum.sum()

    route_poi = Enum.map(wp_list, fn wp -> wp.poi_id end)
    IO.puts("changing cost to #{new_cost}")
    IO.inspect(route_poi, label: "current route")
    new_cost
  end

  defp calculate_travel_cost(wp1, wp2, level, guild_buff) do
    # Waypoint cost = C1 * [ 0.78 + max(0, (0.0003 / 24) * (Distance - 14400)) ] + C2
    c1 = calculate_c1(level)
    c2 = calculate_c2(level)
    distance = distance(wp1, wp2)
    (c1 * (0.78 + max(0, 0.0003 / 24 * (distance - 14400))) + c2) * (1 - guild_buff / 100)
  end

  def distance(wp1, wp2) do
    # IO.inspect([wp1, wp2], label: "waypoints")
    dx = wp2.x - wp1.x
    dy = wp2.y - wp1.y
    # IO.inspect([dx, dy], label: "dx, dy")
    # times 24 because of unit differences
    :math.sqrt(dx * dx + dy * dy) * 24
  end

  @spec calculate_c1(Integer.t()) :: Float.t()
  defp calculate_c1(level) when level >= 0 and level <= 80 do
    23 / 40 * level + 4
    # 0.5823 * level + 3.4177
  end

  @spec calculate_c1(Integer.t()) :: ArgumentError.t()
  defp calculate_c1(level) do
    raise ArgumentError, "Level must be between 0 and 80, got: #{level}"
  end

  @spec calculate_c2(Integer.t()) :: Float.t()
  defp calculate_c2(level) when level >= 0 and level <= 30 do
    0.0
  end

  @spec calculate_c2(Integer.t()) :: Float.t()
  defp calculate_c2(level) when level > 30 and level <= 80 do
    # slope = 1 / 49
    # ceil(slope * (level - 31)) * 100
    2 * level - 60
  end

  @spec calculate_c2(Integer.t()) :: Float.t()
  defp calculate_c2(level) do
    raise ArgumentError, "Level must be between 0 and 80, got: #{level}"
  end

  def build_insert_list(raw_data) do
    raw_data
    |> filter_waypoints()
    |> Enum.uniq_by(& &1["id"])
    |> Enum.map(&transform_data/1)

    # |> Enum.map(fn transformed_wp ->
    # changeset(%Waypoint{}, transformed_wp)
    # end)
  end

  defp transform_data(api_map) do
    %{
      name: api_map["name"],
      x: to_float_robust(Enum.at(api_map["coord"], 0)),
      y: to_float_robust(Enum.at(api_map["coord"], 1)),
      floor: api_map["floor"],
      poi_id: api_map["id"],
      chatlink: api_map["chat_link"]
    }
  end

  defp filter_waypoints(full_result) do
    Enum.flat_map(full_result, fn continent_data ->
      continent_data
      |> Map.get("regions", %{})
      |> Map.values()
      |> Enum.flat_map(fn region ->
        region
        |> Map.get("maps", %{})
        |> Map.values()
        |> Enum.flat_map(fn map_details ->
          map_details
          |> Map.get("points_of_interest", %{})
          |> Map.values()
          |> Enum.filter(fn poi ->
            Map.get(poi, "type") == "waypoint"
          end)
        end)
        |> Enum.map(fn map -> Map.drop(map, ["type"]) end)
      end)
    end)
  end

  defp to_float_robust(value) when is_integer(value), do: value + 0.0
  defp to_float_robust(value) when is_float(value), do: value
  defp to_float_robust(value) when is_binary(value), do: String.to_float(value)
  defp to_float_robust(_), do: {:error, "Unsupported type"}

  defimpl Jason.Encoder, for: Gw2Router.Waypoint do
    def encode(waypoint, opts) do
      %{
        name: waypoint.name,
        x: waypoint.x,
        y: waypoint.y,
        floor: waypoint.floor,
        poi_id: waypoint.poi_id,
        chatlink: waypoint.chatlink
      }
      |> Jason.Encode.map(opts)
    end
  end
end
