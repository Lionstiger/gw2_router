defmodule Gw2RouterWeb.AdminLive do
  use Gw2RouterWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(Gw2Router.PubSub, "admin_page")
    {:ok, socket |> assign(:result, "")}
  end

  @impl true
  def handle_event("refresh_api_data", _params, socket) do
    # Gw2Router.APIRefreshQueu
    Gw2Router.APIRefreshQueue.new(%{})
    |> Oban.insert()

    {:noreply, socket}
  end

  @impl true
  def handle_info({:job_started}, socket) do
    {:noreply, socket |> assign(:result, "In Progress")}
  end

  @impl true
  def handle_info({:job_done, result}, socket) do
    {:noreply, socket |> assign(:result, "Job is done with #{result} waypoints")}
  end

  @impl true
  def handle_info({:job_failed}, socket) do
    {:noreply, socket |> assign(:result, "Job Failed")}
  end
end
