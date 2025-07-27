defmodule Gw2Router.WaypointTest do
  use ExUnit.Case, async: true

  alias Gw2Router.{Waypoint, Repo}
  import Ecto.Adapters.SQL.Sandbox

  setup do
    checkout(Repo)
    all_wp = Repo.all(Waypoint)
    {:ok, all_wp: all_wp}
  end

  describe "calculate_full_route_cost/2" do
    test "Arborstone Waypoint -> Fort Trinity Waypoint", %{all_wp: all_wp} do
      wp1 = Enum.find(all_wp, &(&1.chatlink == "[&BGMNAAA=]"))
      wp2 = Enum.find(all_wp, &(&1.chatlink == "[&BO4CAAA=]"))

      result = Waypoint.calculate_full_route_cost([wp1, wp2], 80, 15)
      assert result == 928
    end

    test "Cornucopian Fields -> Vigil Keep Waypoints", %{all_wp: all_wp} do
      wp1 = Enum.find(all_wp, &(&1.chatlink == "[&BOMAAAA=]"))
      wp2 = Enum.find(all_wp, &(&1.chatlink == "[&BJIBAAA=]"))

      result = Waypoint.calculate_full_route_cost([wp1, wp2], 80, 15)
      assert result == 156
    end

    test "Arborstone Waypoint -> Bastion of Balance Waypoints", %{all_wp: all_wp} do
      wp1 = Enum.find(all_wp, &(&1.chatlink == "[&BGMNAAA=]"))
      wp2 = Enum.find(all_wp, &(&1.chatlink == "[&BD0OAAA=]"))

      result = Waypoint.calculate_full_route_cost([wp1, wp2], 80, 15)
      assert result == 1141
    end
  end
end
