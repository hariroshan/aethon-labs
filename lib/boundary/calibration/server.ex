defmodule ElixirInterviewStarter.Boundary.CalibrationServer do
  @moduledoc """
  Wraps The Core module and builds Genserver

  It holds the current state of calibration for the user
  associated with the email ID

  """
  alias ElixirInterviewStarter.Core.Type.CalibrationSession
  use GenServer

  @type state :: %{
          email: String.t(),
          session: nil | CalibrationSession.t()
        }

  def start_link(opts) do
    email = Keyword.fetch!(opts, :email)
    GenServer.start_link(__MODULE__, email, name: via(email))
  end

  @impl GenServer
  def init(email) do
    {:ok, email}
  end

  def via(email) do
    {:via, Registry, {Registry.Calibration, email}}
  end

  def child_spec(email) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[email: email]]}
    }
  end
end
