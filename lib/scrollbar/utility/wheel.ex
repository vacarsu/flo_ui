defmodule FloUI.Scrollable.Wheel do
  @type wheel_state :: :idle | :scrolling

  @type t :: %__MODULE__{
          wheel_state: wheel_state,
          offset: FloUI.Scrollable.Direction.t()
        }

  defstruct wheel_state: :idle,
            offset: {:horizontal, 0}

  @spec scrolling?(t) :: boolean
  def scrolling?(%{wheel_state: :idle}), do: false

  def scrolling?(%{wheel_state: :scrolling}), do: true

  @spec start_scrolling(t, FloUI.Scrollable.Direction.t()) :: t
  def start_scrolling(state, offset) do
    state
    |> Map.put(:wheel_state, :scrolling)
    |> Map.put(:offset, offset)
  end

  @spec stop_scrolling(t, FloUI.Scrollable.Direction.t()) :: t
  def stop_scrolling(state, offset) do
    state
    |> Map.put(:wheel_state, :idle)
    |> Map.put(:offset, offset)
  end
end
