defmodule StressedoutWeb.Router do
  use StressedoutWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {StressedoutWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", StressedoutWeb do
    pipe_through :browser

    get "/", PageController, :home

    # Testing endpoints
    get "/static", TestController, :static
    get "/dynamic", TestController, :dynamic
    get "/read", TestController, :read
    get "/write", TestController, :write
  end

  # Other scopes may use custom stacks.
  scope "/api", StressedoutWeb do
    pipe_through :api

    # Seeding endpoints
    get "/firstrun", SeedController, :firstrun
    get "/seed", SeedController, :seed

    # created by the generators I used for schema creation
    resources "/users", UserController, except: [:new, :edit]
    resources "/products", ProductController, except: [:new, :edit]
    resources "/orders", OrderController, except: [:new, :edit]
    resources "/reviews", ReviewController, except: [:new, :edit]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:stressedout, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: StressedoutWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
