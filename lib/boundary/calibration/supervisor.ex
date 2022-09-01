defmodule ElixirInterviewStarter.Boundary.CalibrationSupervisor do
  @moduledoc """
  Using Dynamic Supervisor
  """
  use DynamicSupervisor
  alias ElixirInterviewStarter.Boundary.CalibrationServer

  @spec start_link(keyword()) :: Supervisor.on_start()
  def start_link(init_arg) do
    DynamicSupervisor.start_link(
      __MODULE__,
      init_arg,
      name: __MODULE__
    )
  end

  @impl DynamicSupervisor
  @spec init(any()) :: {:ok, DynamicSupervisor.sup_flags()}
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_child(String.t()) :: DynamicSupervisor.on_start_child()
  def start_child(email) do
    DynamicSupervisor.start_child(
      __MODULE__,
      CalibrationServer.child_spec(email)
    )
  end
end
