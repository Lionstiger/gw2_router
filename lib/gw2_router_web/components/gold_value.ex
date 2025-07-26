defmodule Gw2RouterWeb.Components.GoldValue do
  use Phoenix.Component

  attr :always_full, :boolean, default: false
  attr :copper_amount, :integer, default: 5

  def render(assigns) do
    # IO.inspect(assigns)
    all_copper = trunc(assigns.copper_amount)
    {gold, silver, copper} = split_copper(all_copper)

    assigns =
      assigns
      |> assign(:gold, gold)
      |> assign(:silver, silver)
      |> assign(:copper, copper)

    ~H"""
    <div class="flex justify-center items-center pt-4 space-x-1 ">
      {@gold} <img src="/images/18px-Gold_coin.png" width="18" height="18" alt="Gold Coin" />
      {@silver} <img src="/images/18px-Silver_coin.png" width="18" height="18" alt="Silver Coin" />
      {@copper} <img src="/images/18px-Copper_coin.png" width="18" height="18" alt="Copper Coin" />
    </div>
    """
  end

  defp split_copper(all_copper) do
    copper = rem(all_copper, 100)
    all_silver = div(all_copper, 100)

    silver = rem(all_silver, 100)
    gold = div(all_silver, 100)
    {gold, silver, copper}
  end
end
