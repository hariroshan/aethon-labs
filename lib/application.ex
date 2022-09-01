defmodule ElixirInterviewStarter.Application do
  @moduledoc """
  Application module for the our application

  It is the root module that manages the supervisor trees
  and processes
  """

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  use Application
  alias ElixirInterviewStarter.Boundary

  @impl true
  def start(_type, _args) do
    # Childeren for the supervisor
    children = [
      {Registry, keys: :unique, name: Registry.Calibration},
      Boundary.CalibrationSupervisor
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: ElixirInterviewStarter.Supervisor
    )
  end
end
