defmodule Stressedout.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      StressedoutWeb.Telemetry,
      # Start the Ecto repository
      Stressedout.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Stressedout.PubSub},
      # Start Finch
      {Finch, name: Stressedout.Finch},
      # Start the Endpoint (http/https)
      StressedoutWeb.Endpoint
      # Start a worker by calling: Stressedout.Worker.start_link(arg)
      # {Stressedout.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Stressedout.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StressedoutWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
