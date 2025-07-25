defmodule Gw2RouterWeb.Router do
  import Phoenix.LiveView.Router
  import Oban.Web.Router
  use Gw2RouterWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Gw2RouterWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :auth

    defp auth(conn, _opts) do
      username = System.fetch_env!("SETUP_USERNAME")
      password = System.fetch_env!("SETUP_PASSWORD")
      Plug.BasicAuth.basic_auth(conn, username: username, password: password)
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Gw2RouterWeb do
    pipe_through :browser

    # get "/", PageController, :home
    live "/", HomeLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Gw2RouterWeb do
  #   pipe_through :api
  # end

  scope "/admin", Gw2RouterWeb do
    pipe_through [:browser, :admin]
    import Phoenix.LiveDashboard.Router

    live_dashboard "/dashboard", metrics: ArgumentWeb.Telemetry
    # forward "/mailbox", Plug.Swoosh.MailboxPreview

    oban_dashboard("/oban")

    live "/", AdminLive, :index
  end
end
