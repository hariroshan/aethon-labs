defmodule ElixirInterviewStarterTest.Boundary.Calibration do
  @moduledoc """
  Tests the calibration API for the boundary
  """
  use ExUnit.Case, async: true

  alias ElixirInterviewStarter.Boundary.Calibration

  describe "Calibration Boundary API" do
    test "gets current session" do
      email = "hello@mail.com"
      assert :ok == Calibration.start(email)
      assert not is_nil(Calibration.current_session(email))
    end
    test "allows devices msg" do
      email = "hello2@mail.com"
      assert :ok == Calibration.start(email)
      assert :ok == Calibration.device_msg(email, %{"precheck1" => true})
      assert :ok == Calibration.start_precheck_2(email)
      session = Calibration.current_session(email)
      assert session.state == :pre_check2

      assert :ok == Calibration.device_msg(email, %{"cartridgeStatus" => true})
      assert :ok == Calibration.device_msg(email, %{"submergedInWater" => true})

      session = Calibration.current_session(email)
      assert session.state == :calibrate
    end
  end
end
