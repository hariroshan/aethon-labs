defmodule Result do
  @moduledoc """
  Result type has helper functions to handle result tuples
  such as {:ok, any()} | {:error, any()}
  """
  @type result(error, success) :: {:ok, success} | {:error, error}

  @spec map(result(any(), any()), (any() -> any())) :: result(any(), any())
  @doc """
  Map allows the caller to apply a function only when the
  result is :ok or else it returns the error
  """
  def map({:ok, value}, fx), do: {:ok, fx.(value)}
  def map({:error, _} = value, _), do: value

  @spec and_then(result(any(), any()), (any() -> result(any(), any()))) :: result(any(), any())
  @doc """
  and_then allows the caller to chain functions which returns result
  """
  def and_then({:ok, value}, fx), do: fx.(value)
  def and_then({:error, _} = value, _), do: value

  @doc """
  Tap allows you to execute a function with the result value without
  altering the original value
  """
  def tap({:ok, value} = return, fx) do
    fx.(value)
    return
  end

  def tap({:error, _} = return, _), do: return
end
