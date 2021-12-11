defmodule FloUI.Themes do
  @flo_base %{
    text: :white,
    active_text: :black,
    background: :flo_dark_medium_grey,
    highlight: :white,
    border: :light_grey,
    thumb: :steel_blue,
    active: :steel_blue,
    focus: :steel_blue
  }

  @flo_dark Map.merge(@flo_base, %{
    text: :white,
    background: :flo_dark_grey,
    active_text: :white,
    surface: :flo_dark_medium_grey,
    surface_primary: :steel_blue,
    surface_secondary: :flo_medium_grey,
    thumb: :steel_blue,
    active: :flo_blue,
    focus: :flo_blue
  })

  @flo_light Map.merge(@flo_base, %{
    text: :black,
    active_text: :white,
    background: :flo_medium_grey,
  })

  @primary Map.merge(@flo_base, %{
                 text: :black,
                 background: :grey,
                 border: :flo_medium_grey,
                 active: :flo_dark_grey,
                 active_text: :white
               })

  @scrollbar Map.merge(@flo_base, %{
               text: :black,
               background: :grey,
               border: :flo_medium_grey,
               active: :flo_dark_grey,
               active_text: :white
             })

  @primary Map.merge(@flo_base, %{text: :white, background: :steel_blue, active: :flo_blue, active_text: :white})
  @secondary Map.merge(@flo_base, %{background: :flo_light_grey, active: :flo_light_grey, active_text: :black})

  @themes %{
    base: @flo_base,
    dark: @flo_dark,
    light: @flo_light,
    scrollbar: @scrollbar,
    primary: @primary,
    secondary: @secondary,
  }

  @schema [:active_text, :surface, :surface_primary, :surface_secondary]

  @lib [name: :flo_ui, themes: @themes, schema: @schema, palette: FloUI.Palette.get]

  use Scenic.Themes, [
    [name: :scenic, themes: Scenic.Themes],
    @lib
  ]

  def load(), do: @lib

  def get_schema(), do: @schema
end
