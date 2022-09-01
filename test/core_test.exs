defmodule ElixirInterviewStarterTest.CoreTest do
  @moduledoc """
  Test Core Modules which are just a public interface for application
  """

  use ExUnit.Case, async: true
  alias ElixirInterviewStarter.Core

  defp check_send_command(check_command) do
    fn received_command ->
      assert received_command == check_command
    end
  end

  describe "Core Module functions test" do
    test "calibration start" do
      assert {:ok, _} = Core.calibration_start(check_send_command("startPrecheck1"))
    end

    test "calibration start precheck 2" do
      {:ok, session} = Core.calibration_start(check_send_command("startPrecheck1"))

      {:ok, session2} =
        Core.calibration_handle_device_msg(
          session,
          %{"precheck1" => true},
          check_send_command("calibrate")
        )

      {:ok, session3} =
        Core.calibration_handle_device_msg(
          session2,
          %{"cartridgeStatus" => true, "submergedInWater" => true},
          check_send_command("calibrate")
        )

      assert session3.state == :calibrate
    end
  end
end
