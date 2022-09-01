defmodule ElixirInterviewStarter.Core do
  @moduledoc """
  This module is the public API for the Application.

  It delegates to internal modules to solve the business logic.

  Interfaces such as web or elixir processes should use this module to solve the
  business needs

  """

  alias __MODULE__.Calibration
  alias __MODULE__.Type.CalibrationSession

  @spec calibration_start((String.t() -> :ok)) :: {:ok, CalibrationSession.t()}

  @doc """
  Starts new Session

  ## Parameter
  - Send Command function which takes a device command

  ### Returns
  `{:ok, CalibrationSession.t()}`
  """
  defdelegate calibration_start(send_command_fn), to: Calibration, as: :start

  @spec calibration_start(nil | CalibrationSession.t(), (String.t() -> :ok)) ::
          {:ok, CalibrationSession.t()} | {:error, :calibrating}
  @doc """
  Starts new Session when current session is nil
  or else returns error

  ## Parameter
  - nil or CalibrationSession.t()
  - Send Command function which takes a device command

  ### Returns
  `{:ok, CalibrationSession.t()}`
  or
  `{:error, :invalid_state_transition}`
  """
  defdelegate calibration_start(session, send_command_fn), to: Calibration, as: :start

  @spec calibration_start_precheck_2(CalibrationSession.t(), (String.t() -> :ok)) ::
          {:ok, CalibrationSession.t()} | {:error, :invalid_state_transition}
  @doc """
  Starts Precheck 2 by sending the message to the device

  ## Parameter
  - CalibrationSession.t()
  - Send Command function which takes a device command

  ### Returns

  `{:ok, CalibrationSession.t()}`
  or
  `{:error, :invalid_state_transition}`
  """

  defdelegate calibration_start_precheck_2(session, send_command_fn),
    to: Calibration,
    as: :start_precheck_2

  @spec calibration_handle_device_msg(CalibrationSession.t(), map, (String.t() -> :ok)) ::
          {:ok, CalibrationSession.t()} | {:error, :invalid_state_transition}

  @doc """
  Handles the async messages from the device and moves the Calibration Session
  to next valid state.

  ## Parameter
  - CalibrationSession.t()
  - map()
  - Send Command function which takes a device command

  ### Returns
  `{:ok, CalibrationSession.t()}`
  or
  `{:error, :invalid_state_transition}`

  """
  defdelegate calibration_handle_device_msg(calibration_session, params, send_command_fn),
    to: Calibration,
    as: :handle_device_msg
end
