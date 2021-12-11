defmodule FloUI.Palette do
  @palette %{
    flo_dark_grey: {40, 40, 40},
    flo_dark_medium_grey: {64, 64, 64},
    flo_medium_grey: {84, 84, 84},
    flo_light_grey: {162, 162, 162},
    flo_blue: {8, 86, 136},
    flo_purple: {115, 7, 161}
  }

  def get(), do: @palette
end
