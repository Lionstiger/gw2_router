defmodule Gw2RouterWeb.ErrorJSONTest do
  use Gw2RouterWeb.ConnCase, async: true

  test "renders 404" do
    assert Gw2RouterWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert Gw2RouterWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
