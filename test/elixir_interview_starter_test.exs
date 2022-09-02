defmodule ElixirInterviewStarterTest do
  @moduledoc false

  use ExUnit.Case, async: true
  doctest ElixirInterviewStarter

  test "it can go through the whole flow happy path" do
    email = "hello_app@mail.com"
    assert :ok == ElixirInterviewStarter.start(email)
    assert :ok == ElixirInterviewStarter.device_msg(email, %{"precheck1" => true})
    assert :ok == ElixirInterviewStarter.start_precheck_2(email)
    session = ElixirInterviewStarter.get_current_session(email)
    assert session.state == :pre_check2

    assert :ok == ElixirInterviewStarter.device_msg(email, %{"cartridgeStatus" => true})
    assert :ok == ElixirInterviewStarter.device_msg(email, %{"submergedInWater" => true})

    session = ElixirInterviewStarter.get_current_session(email)
    assert session.state == :calibrate

    assert :ok == ElixirInterviewStarter.device_msg(email, %{"calibrated" => true})
    session = ElixirInterviewStarter.get_current_session(email)

    assert session.state == :completed
  end

  test "start/1 creates a new calibration session and starts precheck 1" do
    email = "hello_app_prech@mail.com"
    assert :ok == ElixirInterviewStarter.start(email)
    session = ElixirInterviewStarter.get_current_session(email)

    assert session.state == :pre_check1

    assert :ok == ElixirInterviewStarter.device_msg(email, %{"precheck1" => true})
    session = ElixirInterviewStarter.get_current_session(email)
    assert session.state == :pre_check2
  end

  test "start/1 returns an error if the provided user already has an ongoing calibration session" do
    email = "hello_cali_start@mail.com"
    assert :ok == ElixirInterviewStarter.start(email)

    assert {:error, :calibrating} == ElixirInterviewStarter.start(email)
  end

  test "start_precheck_2/1 starts precheck 2" do
    email = "start_precheck_2@mail.com"
    assert :ok == ElixirInterviewStarter.start(email)
    assert :ok == ElixirInterviewStarter.device_msg(email, %{"precheck1" => true})

    assert :ok == ElixirInterviewStarter.start_precheck_2(email)
    session = ElixirInterviewStarter.get_current_session(email)
    assert session.state == :pre_check2

    assert :ok == ElixirInterviewStarter.device_msg(email, %{"cartridgeStatus" => true})
    assert :ok == ElixirInterviewStarter.device_msg(email, %{"submergedInWater" => true})

    session = ElixirInterviewStarter.get_current_session(email)

    assert session.state == :calibrate
  end

  test "start_precheck_2/1 returns an error if the provided user does not have an ongoing calibration session" do
    email = "hello_error_start_precheck_2@mail.com"
    assert {:error, :invalid_state_transition} == ElixirInterviewStarter.start_precheck_2(email)
  end

  test "start_precheck_2/1 returns an error if the provided user's ongoing calibration session is not done with precheck 1" do
    email = "hello_error_start_precheck_1_not_complet@mail.com"
    assert :ok == ElixirInterviewStarter.start(email)
    assert {:error, :invalid_state_transition} == ElixirInterviewStarter.start_precheck_2(email)
  end

  test "start_precheck_2/1 returns an error if the provided user's ongoing calibration session is already done with precheck 2" do
    email = "start_precheck_2start_precheck_2/1_returns_an_error@mail.com"
    assert :ok == ElixirInterviewStarter.start(email)
    assert :ok == ElixirInterviewStarter.device_msg(email, %{"precheck1" => true})

    assert :ok == ElixirInterviewStarter.start_precheck_2(email)
    session = ElixirInterviewStarter.get_current_session(email)
    assert session.state == :pre_check2

    assert :ok == ElixirInterviewStarter.device_msg(email, %{"cartridgeStatus" => true})
    assert :ok == ElixirInterviewStarter.device_msg(email, %{"submergedInWater" => true})

    assert {:error, :invalid_state_transition} == ElixirInterviewStarter.start_precheck_2(email)
  end

  test "get_current_session/1 returns the provided user's ongoing calibration session" do
    email = "random@mai"
    assert :ok == ElixirInterviewStarter.start(email)
    session = ElixirInterviewStarter.get_current_session(email)

    assert session.state == :pre_check1
    assert session.finished == false

    assert :ok == ElixirInterviewStarter.device_msg(email, %{"precheck1" => true})

    session = ElixirInterviewStarter.get_current_session(email)

    assert session.state == :pre_check2
    assert session.finished == false
  end

  test "get_current_session/1 returns nil if the provided user has no ongoing calibrationo session" do
    assert is_nil(ElixirInterviewStarter.get_current_session("emailRandowm"))
  end
end
