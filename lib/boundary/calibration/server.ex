defmodule ElixirInterviewStarter.Boundary.CalibrationServer do
  @moduledoc """
  Wraps The Core module and builds Genserver

  It holds the current state of calibration for the user
  associated with the email ID

  """
  use GenServer

  alias ElixirInterviewStarter.Core.Type.CalibrationSession
  alias ElixirInterviewStarter.Core
  alias ElixirInterviewStarter.DeviceMessages

  @type state :: %{
          email: String.t(),
          session: nil | CalibrationSession.t()
        }

  @registry_name Registry.Calibration

  # Client API

  @spec device_msg(pid(), map()) :: :ok | {:error, :invalid_state_transition}
  @doc """
  Forwards the device messages to the Genserver process
  """
  def device_msg(pid, parameter) when is_pid(pid) and is_map(parameter) do
    GenServer.call(pid, {:device_msg, parameter})
  end

  @spec start(pid()) :: :ok | {:error, :calibrating}
  @doc """
  Since pid already exists, It will return {:error, :calibrating}
  because the session already started
  """
  def start(pid) do
    GenServer.call(pid, :start)
  end

  @spec start_precheck_2(pid()) :: :ok | {:error, :invalid_state_transition}
  @doc """
  Forwards the pre_check_2, to the Genserver process
  Starts pre_check_2 state transtion on the session if it is valid
  """
  def start_precheck_2(pid) do
    GenServer.call(pid, :start_precheck_2)
  end

  @spec current_session(pid()) :: CalibrationSession.t()
  @doc """
  Returns the Current ongoing session
  """
  def current_session(pid) do
    GenServer.call(pid, :current_session)
  end

  # GenServer Related Functions

  def start_link(opts) do
    email = Keyword.fetch!(opts, :email)
    GenServer.start_link(__MODULE__, email, name: via(email))
  end

  @spec lookup(String.t()) :: nil | pid()
  def lookup(email) do
    Registry.lookup(@registry_name, via(email))
    |> case do
      [{pid, _}] -> pid
      _ -> nil
    end
  end

  def child_spec(email) do
    %{
      id: __MODULE__,
      type: :worker,
      start: {__MODULE__, :start_link, [[email: email]]},
      restart: :transient
    }
  end

  # OTP CALLBACKS

  @impl GenServer
  @spec init(String.t()) :: {:ok, state(), pos_integer()}
  def init(email) do
    {:ok, session} =
      email
      |> send_command
      |> Core.calibration_start()

    {:ok, %{email: email, session: session}, session.timeout}
  end

  @impl GenServer
  def handle_call({:device_msg, parameters}, _from, state) do
    state.session
    |> Core.calibration_handle_device_msg(parameters, send_command(state.email))
    |> map_to_reply_if_valid_or_stop_session(state)
  end

  def handle_call(:start, _, state) do
    state.session
    |> Core.calibration_start(send_command(state.email))
    |> map_to_reply_if_valid_or_stop_session(state)
  end

  def handle_call(:start_precheck_2, _, state) do
    state.session
    |> Core.calibration_start_precheck_2(send_command(state.email))
    |> map_to_reply_if_valid_or_stop_session(state)
  end

  def handle_call(:current_session, _, state) do
    {:reply, state.session, state}
  end

  defp map_to_reply_if_valid_or_stop_session(result, state) do
    case result do
      {:ok, session} ->
        {:reply, :ok, %{state | session: session}, session.timeout}

      {:error, _} = err ->
        {:stop, err, err, state}
    end
  end

  defp send_command(user_email) do
    fn command -> DeviceMessages.send(user_email, command) end
  end

  defp via(email) do
    {:via, Registry, {@registry_name, email}}
  end
end
