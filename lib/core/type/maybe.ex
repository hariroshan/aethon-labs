defmodule Maybe do
  @moduledoc """
  Maybe module is used to handle nil values safely

  It allows you to apply functions safely when a value could be nil | value
  """
  @type t :: nil | any()

  @spec map(nil | any(), (any() -> any())) :: nil | any()
  def map(nil, _), do: nil
  def map(value, fx), do: fx.(value)

  @spec map_nil(nil | any(), fun()) :: any()
  def map_nil(nil, fx), do: fx.()
  def map_nil(value, _), do: value

  @spec with_default(nil | any(), any()) :: any()
  def with_default(nil, default), do: default
  def with_default(value, _), do: value
end
