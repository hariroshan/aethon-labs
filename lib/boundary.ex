defmodule ElixirInterviewStarter.Boundary do
  @moduledoc """
  Public API to use the Genservers, Supervisors and other OTP stuff.
  *Only delegates to relative modules*

  Implementation of GenServers, Supervisors, Ets tables and other
  OTP related concepts.

  It uses the Core module, OTP and other Elixir related structure to achieve the business needs
  and scale it multiple processors and servers

  """
  alias __MODULE__.Calibration
  alias ElixirInterviewStarter.Core.Type.CalibrationSession

  @spec calibrate_start(String.t()) :: :ok | {:error, :invalid_state_transition}
  @doc """
  Starts a new session only when the session doesn't exist.
  If it does, function will return :error
  """
  defdelegate calibrate_start(email), to: Calibration, as: :start

  @spec calibrate_handle_msg(String.t(), map()) :: :ok | {:error, :invalid_state_transition}
  @doc """
  Messages from the device is routed to the session if it exists
  or else it returns error
  """
  defdelegate calibrate_handle_msg(email, parameter), to: Calibration, as: :handle_msg

  @spec calibrate_start_precheck_2(String.t()) :: :ok | {:error, :invalid_state_transition}
  @doc """
  Starts pre check 2 for the given Email ID
  returns error if the session doesn't exists or if invalid state transition is performed
  """
  defdelegate calibrate_start_precheck_2(email), to: Calibration, as: :start_precheck_2

  @spec calibrate_current_session(String.t()) :: nil | CalibrationSession.t()
  @doc """
  Gets the current CalibrationSession for the given Email or nil if no session
  """
  defdelegate calibrate_current_session(email), to: Calibration, as: :current_session
end
