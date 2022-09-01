defmodule ElixirInterviewStarterTest.Core.Type.CalibrationSessionTest do
  @moduledoc """
  Tests the Calibration Session Type and its functions
  """

  use ExUnit.Case, async: true
  alias ElixirInterviewStarter.Core.Type.CalibrationSession

  describe "Calibration Session Type functions test" do
    test "creates new CalibrationSession" do
      session = CalibrationSession.new()

      assert session.state == :pre_check1
      assert session.finished == false
      assert session.pre_check_2_data == nil
    end

    test "checks if the to_state_command/1 returns correct strings " do
      session = CalibrationSession.new()

      assert {:ok, "startPrecheck1"} == CalibrationSession.to_state_command(session)

      assert {:ok, "startPrecheck2"} ==
               CalibrationSession.to_state_command(%{
                 session
                 | state: :pre_check2,
                   finished: false
               })

      assert {:ok, "calibrate"} ==
               CalibrationSession.to_state_command(%{
                 session
                 | state: :calibrate
               })
    end

    test "checks if the to_state_command/1 returns :error for invalid states " do
      session = CalibrationSession.new()

      assert {:error, :invalid_state_transition} ==
               CalibrationSession.to_state_command(%{session | finished: true})

      assert {:error, :invalid_state_transition} ==
               CalibrationSession.to_state_command(%{
                 session
                 | state: :pre_check2,
                   finished: true
               })

      assert {:error, :invalid_state_transition} ==
               CalibrationSession.to_state_command(%{
                 session
                 | state: :calibrate,
                   finished: true
               })

      assert {:error, :invalid_state_transition} ==
               CalibrationSession.to_state_command(%{
                 session
                 | state: :completed,
                   finished: true
               })
    end

    test "checks if session is completed" do
      session = CalibrationSession.new()

      refute CalibrationSession.is_calibration_completed?(session)
      assert CalibrationSession.is_calibration_completed?(%{session | state: :completed})
    end

    test "handles pre check1 message from device" do
      session = CalibrationSession.new()

      completed_pre_check1 =
        session
        |> CalibrationSession.handle_device_msg(%{"precheck1" => true})

      assert {:ok, %{session | state: :pre_check2, finished: false}} == completed_pre_check1

      error_pre_check1 =
        session
        |> CalibrationSession.handle_device_msg(%{"precheck1" => false})

      assert CalibrationSession.invalid_state_transition() == error_pre_check1
    end

    test "handles pre check2 message from device" do
      session = CalibrationSession.new()

      {:ok, session2} =
        session
        |> CalibrationSession.handle_device_msg(%{"precheck1" => true})

      {:ok, partial_completed_precheck2} =
        session2
        |> CalibrationSession.handle_device_msg(%{"cartridgeStatus" => true})

      assert %{
               session
               | state: :pre_check2,
                 finished: false,
                 pre_check_2_data: %{cartridge_status: true, submerged_in_water: nil}
             } ==
               partial_completed_precheck2

      assert {:ok, %{session | state: :calibrate, finished: false}} ==
               partial_completed_precheck2
               |> CalibrationSession.handle_device_msg(%{"submergedInWater" => true})

      assert CalibrationSession.invalid_state_transition() ==
               partial_completed_precheck2
               |> CalibrationSession.handle_device_msg(%{"submergedInWater" => false})

      assert {:ok,
              %{
                session
                | state: :pre_check2,
                  finished: false,
                  pre_check_2_data: %{cartridge_status: false, submerged_in_water: nil}
              }} ==
               partial_completed_precheck2
               |> CalibrationSession.handle_device_msg(%{"cartridgeStatus" => false})
    end

    test "handles calibrate message from device" do
      session = CalibrationSession.new()

      with {:ok, prechecked} <-
             CalibrationSession.handle_device_msg(session, %{"precheck1" => true}),
           {:ok, prechecked2} <-
             CalibrationSession.handle_device_msg(prechecked, %{
               "cartridgeStatus" => true,
               "submergedInWater" => true
             }) do
        assert {:ok, %{prechecked2 | state: :completed, finished: true}} ==
                 CalibrationSession.handle_device_msg(prechecked2, %{"calibrated" => true})

        assert CalibrationSession.invalid_state_transition() ==
                 CalibrationSession.handle_device_msg(prechecked2, %{"calibrated" => false})
      end
    end
  end
end
