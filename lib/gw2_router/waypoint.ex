defmodule Gw2Router.Waypoint do
  use Ecto.Schema
  import Ecto.Changeset

  schema "waypoints" do
    field :name, :string
    field :x, :float
    field :y, :float
    field :floor, :integer
    field :poi_id, :integer
    field :chatlink, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(waypoint, attrs) do
    waypoint
    |> cast(attrs, [:name, :floor, :x, :y, :poi_id, :chatlink])
    |> validate_required([:name, :floor, :x, :y, :poi_id, :chatlink])
  end
end
