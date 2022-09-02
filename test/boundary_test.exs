defmodule ElixirInterviewStarterTest.BoundaryTest do
  @moduledoc """
  Tests the boundary API
  """
  use ExUnit.Case, async: true

  alias ElixirInterviewStarter.Boundary

  describe "Calibration Boundary api" do
    test "calibration flow" do
      email = "hello_boundary@mail.com"
      assert :ok == Boundary.calibrate_start(email)
      assert :ok == Boundary.calibrate_device_msg(email, %{"precheck1" => true})
      assert :ok == Boundary.calibrate_start_precheck_2(email)
      session = Boundary.calibrate_current_session(email)
      assert session.state == :pre_check2

      assert :ok == Boundary.calibrate_device_msg(email, %{"cartridgeStatus" => true})
      assert :ok == Boundary.calibrate_device_msg(email, %{"submergedInWater" => true})

      session = Boundary.calibrate_current_session(email)
      assert session.state == :calibrate

      assert :ok == Boundary.calibrate_device_msg(email, %{"calibrated" => true})
      session = Boundary.calibrate_current_session(email)

      assert session.state == :completed
    end
  end
end
