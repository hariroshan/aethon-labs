defmodule ElixirInterviewStarterTest.Boundary.CalibrationSupervisorTest do
  @moduledoc """
  Tests the Calibration Supervisor
  """
  use ExUnit.Case, async: true
  alias ElixirInterviewStarter.Boundary.CalibrationSupervisor

  describe "Calibration Supervisor test" do
    test "starts child" do
      {:ok, pid} = CalibrationSupervisor.start_child("email")
      assert is_pid(pid)
    end
  end
end
