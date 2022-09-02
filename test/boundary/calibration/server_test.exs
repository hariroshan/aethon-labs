defmodule ElixirInterviewStarterTest.Boundary.CalibrationServerTest do
  @moduledoc """
  Tests the Calibration Genserver Server
  """
  use ExUnit.Case, async: true

  alias ElixirInterviewStarter.Boundary.CalibrationServer, as: Server

  describe "caliberation server" do
    test "starts the server" do
      {:ok, pid} = Server.start_link(email: "hello@mail.com")
      assert is_pid(pid)
    end

    test "gets the Current Session" do
      {:ok, pid} = Server.start_link(email: "hello@mail.com")
      session = Server.current_session(pid)
      assert session.state == :pre_check1
    end

    test "calls precheck2" do
      email = "hello@mail.com"
      {:ok, pid} = Server.start_link(email: email)
      assert {:error, :invalid_state_transition} == Server.start_precheck_2(pid)
    end

    test "tests devices message" do
      email = "hello@mail.com"
      {:ok, pid} = Server.start_link(email: email)
      assert :ok == Server.device_msg(pid, %{"precheck1" => true})
      session = Server.current_session(pid)
      assert session.state == :pre_check2
    end
  end
end
