defmodule ElixirInterviewStarter.Core.Type.CalibrationSession do
  @moduledoc """
  A struct representing an ongoing calibration session, used to identify who the session
  belongs to, what step the session is on, and any other information relevant to working
  with the session.
  """

  @type state ::
          :pre_check1
          | :pre_check2
          | :calibrate
          | :completed

  @type t() :: %__MODULE__{
          state: state(),
          finished: boolean(),
          timeout: timeout()
        }

  # one minute
  @timeout 1000 * 30

  defstruct ~w(
    state
    finished
    timeout
    pre_check_2_data
  )a

  @spec new :: __MODULE__.t()
  @doc """
  Starts a new Calibration Session
  """
  def new do
    struct!(__MODULE__,
      state: :pre_check1,
      finished: false,
      timeout: @timeout,
      pre_check_2_data: nil
    )
  end

  @spec to_state_command(__MODULE__.t()) :: {:ok, String.t()} | {:error, :invalid_state_transition}
  @doc """
  Serialize the current calibration session to a string.
  This string is pushed to the device.
  It is only possible to create this string only when the current state is not finished.

  ## Parameter
  - CalibrationSession.t()

  ### Returns
    `string`
  """
  def to_state_command(%__MODULE__{state: :pre_check1, finished: false}) do
    {:ok, "startPrecheck1"}
  end

  def to_state_command(%__MODULE__{state: :pre_check2, finished: false, pre_check_2_data: nil}) do
    {:ok, "startPrecheck2"}
  end

  def to_state_command(%__MODULE__{state: :calibrate, finished: false}) do
    {:ok, "calibrate"}
  end

  def to_state_command(_), do: invalid_state_transition()

  @spec is_calibration_completed?(__MODULE__.t()) :: boolean()
  @doc """
  Checks whether the current calibration session is completed
  ## Parameter
  - CalibrationSession.t()

  ### Returns
    `boolean`
  """
  def is_calibration_completed?(%__MODULE__{state: :completed}), do: true
  def is_calibration_completed?(_), do: false

  @spec handle_device_msg(__MODULE__.t(), map) ::
          {:ok, __MODULE__.t()} | {:error, :invalid_state_transition}
  @doc """
  Handles the async messages from the device and moves the Calibration Session
  to next valid state.

  ## Parameter
  - CalibrationSession.t()
  - map() *message from the device*

  ### Returns
  `{:ok, CalibrationSession.t()}`
  or
  `{:error, :invalid_state_transition}`

  """

  def handle_device_msg(
        %__MODULE__{
          state: :pre_check1,
          finished: false
        } = calibration_session,
        %{"precheck1" => true}
      ) do
    %{calibration_session | finished: true} |> to_next_state()
  end

  def handle_device_msg(
        %__MODULE__{
          state: :pre_check2,
          finished: false,
          pre_check_2_data: data
        } = calibration_session,
        params
      ) do
    pre_check2_data = pre_check_2_data_from_param(data, params)
    status = pre_check_2_params_status(pre_check2_data)

    cond do
      is_nil(status) ->
        {:ok, %{calibration_session | pre_check_2_data: pre_check2_data}}

      status ->
        %{calibration_session | finished: true, pre_check_2_data: nil} |> to_next_state()

      true ->
        invalid_state_transition()
    end
  end

  def handle_device_msg(
        %__MODULE__{
          state: :calibrate,
          finished: false
        } = calibration_session,
        %{
          "calibrated" => true
        }
      ),
      do: %{calibration_session | finished: true} |> to_next_state()

  def handle_device_msg(_, _), do: invalid_state_transition()

  def invalid_state_transition, do: {:error, :invalid_state_transition}

  def allow_calibration?(%__MODULE__{state: :calibrate, finished: false}), do: true
  def allow_calibration?(_), do: false

  defp pre_check_2_data_from_param(nil, param) do
    %{
      cartridge_status: Map.get(param, "cartridgeStatus"),
      submerged_in_water: Map.get(param, "submergedInWater")
    }
  end

  defp pre_check_2_data_from_param(data, param) do
    data
    |> Map.update!(:cartridge_status, fn
      nil -> Map.get(param, "cartridgeStatus")
      value -> Map.get(param, "cartridgeStatus", value)
    end)
    |> Map.update!(:submerged_in_water, fn
      nil -> Map.get(param, "submergedInWater")
      value -> Map.get(param, "submergedInWater", value)
    end)
  end

  defp pre_check_2_params_status(%{cartridge_status: nil}) do
    nil
  end

  defp pre_check_2_params_status(%{submerged_in_water: nil}) do
    nil
  end

  defp pre_check_2_params_status(%{
         cartridge_status: cartridge_status,
         submerged_in_water: submerged_in_water
       })
       when not is_nil(cartridge_status) and not is_nil(submerged_in_water),
       do: cartridge_status && submerged_in_water

  @spec to_next_state(__MODULE__.t()) ::
          {:ok, __MODULE__.t()} | {:error, :invalid_state_transition}
  defp to_next_state(%__MODULE__{state: :pre_check1, finished: true} = calibration) do
    {:ok, %{calibration | state: :pre_check2, finished: false}}
  end

  defp to_next_state(%__MODULE__{state: :pre_check2, finished: true} = calibration) do
    {:ok, %{calibration | state: :calibrate, finished: false}}
  end

  defp to_next_state(%__MODULE__{state: :calibrate, finished: true} = calibration) do
    {:ok, %{calibration | state: :completed, finished: true}}
  end
end
