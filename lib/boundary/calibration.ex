defmodule ElixirInterviewStarter.Boundary.Calibration do
  @moduledoc """
  API for interacting with Calibration Supervior and Server
  """

  alias ElixirInterviewStarter.Boundary.CalibrationSupervisor
  alias ElixirInterviewStarter.Boundary.CalibrationServer
  alias ElixirInterviewStarter.Core.Type.CalibrationSession

  @spec start(String.t()) :: :ok | {:error, :invalid_state_transition}
  @doc """
  Starts a new session only when the session doesn't exist.
  If it does, function will return :error
  """
  def start(email) do
    case CalibrationServer.lookup(email) do
      nil ->
        CalibrationSupervisor.start_child(email)
        :ok

      pid ->
        # This will return {:error, :invalid_state_transition}
        # Since the session already started
        CalibrationServer.start(pid)
    end
  end

  @spec handle_msg(String.t(), map()) :: :ok | {:error, :invalid_state_transition}
  @doc """
  Messages from the device is routed to the session if it exists
  or else it returns error
  """
  def handle_msg(email, parameter) when is_binary(email) and is_map(parameter) do
    email
    |> apply_function_only_when_session_exists(fn pid ->
      CalibrationServer.device_msg(pid, parameter)
    end)
  end

  @spec start_precheck_2(String.t()) :: :ok | {:error, :invalid_state_transition}
  @doc """
  Starts pre check 2 for the given Email ID
  returns error if the session doesn't exists or if invalid state transition is performed
  """
  def start_precheck_2(email) do
    email
    |> apply_function_only_when_session_exists(&CalibrationServer.start_precheck_2/1)
  end

  @spec current_session(String.t()) :: nil | CalibrationSession.t()
  @doc """
  Gets the current CalibrationSession from the Genserver
  """
  def current_session(email) do
    CalibrationServer.lookup(email)
    |> Maybe.map(&CalibrationServer.current_session/1)
  end

  defp apply_function_only_when_session_exists(email, fx) do
    CalibrationServer.lookup(email)
    # Session probably Timeout when lookup returns nil
    |> Maybe.map_nil(fn -> {:error, :invalid_state_transition} end)
    # This code is executed only when lookup returns pid value which is session process
    |> Maybe.map(fx)
  end
end
