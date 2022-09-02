defmodule ElixirInterviewStarter do
  @moduledoc """
  See `README.md` for instructions on how to approach this technical challenge.
  """

  alias ElixirInterviewStarter.Core.Type.CalibrationSession
  alias __MODULE__.Boundary

  @spec start(user_email :: String.t()) :: :ok | {:error, :invalid_state_transition}
  @doc """
  Creates a new `CalibrationSession` for the provided user, starts a `GenServer` process
  for the session, and starts precheck 1.

  If the user already has an ongoing `CalibrationSession`, returns an error.
  """
  def start(user_email) do
    Boundary.calibrate_start(user_email)
  end

  @spec start_precheck_2(user_email :: String.t()) :: :ok | {:error, :invalid_state_transition}
  @doc """
  Starts the precheck 2 step of the ongoing `CalibrationSession` for the provided user.

  If the user has no ongoing `CalibrationSession`, their `CalibrationSession` is not done
  with precheck 1, or their calibration session has already completed precheck 2, returns
  an error.
  """
  def start_precheck_2(user_email) do
    Boundary.calibrate_start_precheck_2(user_email)
  end

  @spec get_current_session(user_email :: String.t()) :: CalibrationSession.t() | nil
  @doc """
  Retrieves the ongoing `CalibrationSession` for the provided user, if they have one
  """
  def get_current_session(user_email) do
    Boundary.calibrate_current_session(user_email)
  end

  @spec device_msg(String.t(), map()) :: :ok | {:error, :invalid_state_transition}
  @doc """
  Messages from the Devices can be sent to this function.
  """
  def device_msg(user_email, parameter) do
    Boundary.calibrate_device_msg(user_email, parameter)
  end
end
