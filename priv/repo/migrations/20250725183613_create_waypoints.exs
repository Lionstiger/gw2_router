defmodule Gw2Router.Repo.Migrations.CreateWaypoints do
  use Ecto.Migration

  def change do
    create table(:waypoints) do
      add :name, :string
      add :floor, :integer
      add :x, :float
      add :y, :float
      add :poi_id, :integer
      add :chatlink, :string

      timestamps(type: :utc_datetime)
    end
  end
end
