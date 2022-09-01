defmodule ElixirInterviewStarter.Core.Calibration do
  @moduledoc """
  Models the caliberation flow using the `CalibrationSession`
  """

  alias ElixirInterviewStarter.Core.Type.CalibrationSession

  @type error :: :calibrating | :invalid_state_transition

  @doc """
  Starts new Session when given current session
  ## Parameter
  - Current session if user has any or nil
  - Send Command function which takes a device command

  ### Returns
  `{:ok, CalibrationSession.t()}`
  or
  `{:error, :calibrating}`
  """
  @spec start((String.t() -> :ok)) :: {:ok, CalibrationSession.t()}
  def start(send_command), do: send_session_command(CalibrationSession.new(), send_command)

  @spec start(nil | any(), (String.t() -> :ok)) ::
          {:ok, CalibrationSession.t()} | {:error, :calibrating}
  def start(nil, send_command), do: send_session_command(CalibrationSession.new(), send_command)
  def start(_, _), do: {:error, :calibrating}

  @spec start_precheck_2(CalibrationSession.t(), (String.t() -> :ok)) ::
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
  def start_precheck_2(%CalibrationSession{state: :pre_check2} = session, send_command) do
    session
    |> send_session_command(send_command)
  end

  def start_precheck_2(_, _), do: CalibrationSession.invalid_state_transition()

  @spec handle_device_msg(CalibrationSession.t(), map, (String.t() -> :ok)) ::
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
  def handle_device_msg(calibration_session, params, send_command) do
    CalibrationSession.handle_device_msg(calibration_session, params)
    |> Result.and_then(fn result ->
      if CalibrationSession.allow_calibration?(result) do
        send_session_command(result, send_command)
      else
        {:ok, result}
      end
    end)
  end

  defp send_session_command(session, send_command) do
    CalibrationSession.to_state_command(session)
    |> Result.tap(send_command)
    |> Result.map(fn _ -> session end)
  end
end
