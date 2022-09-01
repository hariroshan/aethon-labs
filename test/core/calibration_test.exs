defmodule ElixirInterviewStarterTest.Core.CalibrationTest do
  @moduledoc """
  Tests the Calibration module which uses the Calibration session
  """
  use ExUnit.Case, async: true
  alias ElixirInterviewStarter.Core.Calibration
  alias ElixirInterviewStarter.Core.Type.CalibrationSession

  defp check_send_command(check_command) do
    fn received_command ->
      assert received_command == check_command
    end
  end

  describe "Calibration module test" do
    test "starts calibration without any params" do
      session = CalibrationSession.new()
      assert {:ok, session} == Calibration.start(check_send_command("startPrecheck1"))
    end

    test "handles message from device" do
      {:ok, session} = Calibration.start(check_send_command("startPrecheck1"))

      {:ok, session2} =
        Calibration.handle_device_msg(session, %{"precheck1" => true}, check_send_command("calibrate"))

      assert %{session | state: :pre_check2, finished: false} == session2
    end

    test "starts pre check 2 after recieving message from device" do
      {:ok, session} = Calibration.start(check_send_command("startPrecheck1"))

      {:ok, session2} =
        Calibration.handle_device_msg(session, %{"precheck1" => true}, check_send_command("calibrate"))

      {:ok, session3} = Calibration.start_precheck_2(session2, check_send_command("startPrecheck2"))
      assert session2 == session3
    end

    test "starts calibration after recieving message from device" do
      {:ok, session} = Calibration.start(check_send_command("startPrecheck1"))
      {:ok, session2} = Calibration.handle_device_msg(session, %{"precheck1" => true}, check_send_command("calibrate"))
      {:ok, session3} = Calibration.start_precheck_2(session2, check_send_command("startPrecheck2"))

      {:ok, session4} =
        Calibration.handle_device_msg(
          session3,
          %{
            "cartridgeStatus" => true,
            "submergedInWater" => true
          },
          check_send_command("calibrate")
        )
      assert session4 == %{session3 | state: :calibrate, finished: false}
    end

  end
end
