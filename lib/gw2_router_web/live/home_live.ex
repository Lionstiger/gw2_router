defmodule Gw2RouterWeb.HomeLive do
  alias Gw2Router.RoutingRequest
  alias Gw2Router.Waypoint
  alias Gw2RouterWeb.Components.GoldValue
  alias Ecto.UUID
  use Gw2RouterWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    page_id = UUID.generate()
    Phoenix.PubSub.subscribe(Gw2Router.PubSub, "route_#{page_id}")

    {:ok,
     socket
     |> assign(:status, "Idle")
     |> assign(:page_id, page_id)
     |> assign(:wp_copybuffer, "")
     # Not used yet
     |> assign(:old_cost, 0.0)
     |> assign(:cost, 0.0)
     |> assign(:level, 80)
     |> assign(:guild_buff, 0)
     |> assign(:wp_text, "")
     |> assign(:wp_list, [])}
  end

  defp assign_request_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "routing_request")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end

  @impl true
  def handle_event("waypoint_text_edited", %{"wp_text" => wp_input}, socket) do
    found_wp = Gw2Router.WaypointChecker.search(wp_input)

    # new_text =
    #   Enum.reduce(Enum.map(found_wp, fn wp -> wp.chatlink end), wp_input, fn substring, acc ->
    #     String.replace(acc, substring, "")
    #   end)

    IO.inspect(socket.assigns.level)
    # {:noreply, socket |> assign(:wp_list, socket.assigns.wp_list ++ found_wp)}
    {:noreply,
     socket
     |> assign(:wp_list, found_wp)
     |> assign(:wp_copybuffer, Waypoint.copy_buffer(socket.assigns.wp_list))
     |> assign(
       :cost,
       Waypoint.calculate_full_route_cost(
         socket.assigns.wp_list,
         socket.assigns.level,
         socket.assigns.guild_buff
       )
     )}
  end

  @impl true
  def handle_event(
        "level_changed",
        %{"level" => level},
        socket
      ) do
    IO.puts("Level Updated #{level}")

    {:noreply,
     socket
     |> assign(:level, String.to_integer(level))
     |> assign(
       :cost,
       Waypoint.calculate_full_route_cost(
         socket.assigns.wp_list,
         String.to_integer(level),
         socket.assigns.guild_buff
       )
     )}
  end

  @impl true
  def handle_event(
        "guild_buff_changed",
        %{"guild_buff" => gb_string},
        socket
      ) do
    guild_buff =
      case gb_string do
        "0%" -> 0
        "5%" -> 5
        "10%" -> 10
        "15%" -> 15
      end

    IO.puts("Guild Buff updated #{guild_buff}")

    {:noreply,
     socket
     |> assign(:guild_buff, guild_buff)
     |> assign(
       :cost,
       Waypoint.calculate_full_route_cost(
         socket.assigns.wp_list,
         socket.assigns.level,
         guild_buff
       )
     )}
  end

  @impl true
  def handle_event("route_request", %{"level" => level}, socket) do
    # IO.inspect(params)
    wp_list = socket.assigns.wp_list
    page_id = socket.assigns.page_id

    Gw2Router.RoutingQueue.new(%{page_id: page_id, level: level, wp_list: wp_list})
    |> Oban.insert()

    {:noreply,
     socket
     |> push_event("clear-input", %{id: "wp_text_input"})
     # |> put_flash(:info, "Queued")
     |> assign(:status, "Queued")}
  end

  @impl true
  def handle_event("delete", %{"index" => index}, socket) do
    {:noreply,
     socket
     |> assign(:wp_copybuffer, Waypoint.copy_buffer(socket.assigns.wp_list))
     |> assign(:wp_list, List.delete_at(socket.assigns.wp_list, index))}
  end

  def split_by_whitespace_and_tab(text) do
    String.split(text, ~r/\s+/, trim: true)
  end

  @impl true
  def handle_info({:job_started}, socket) do
    {:noreply, socket |> assign(:status, "In Progress")}
  end

  @impl true
  def handle_info({:job_done, %{new_list: updated_list, level: level}}, socket) do
    # IO.inspect(updated_list)

    {:noreply,
     socket
     |> assign(:status, "Done")
     |> assign(:wp_list, updated_list)
     |> assign(
       :cost,
       Waypoint.calculate_full_route_cost(updated_list, level, socket.assigns.guild_buff)
     )}
  end

  @impl true
  def handle_info({:job_started}, socket) do
    {:noreply, socket |> assign(:status, "In Progress")}
  end
end
