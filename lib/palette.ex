defmodule FloUI.Palette do
  @palette %{
    flo_dark_grey: {40, 40, 40},
    flo_dark_medium_grey: {64, 64, 64},
    flo_medium_grey: {84, 84, 84},
    flo_light_grey: {111, 117, 125},
    flo_blue: {8, 86, 136},

  }

  def get(), do: @palette
end
