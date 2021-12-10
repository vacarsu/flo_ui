defmodule FloUI.Themes do
  @flo_base %{
    text: :white,
    active_text: :black,
    background: {64, 64, 64},
    highlight: :white,
    border: :light_grey,
    active: :steel_blue,
    thumb: :steel_blue,
    focus: :steel_blue
  }

  @flo_dark Map.merge(@flo_base, %{text: :white, background: :black})
  @flo_light Map.merge(@flo_base, %{text: :black, background: :gainsboro})

  @flo_primary Map.merge(@flo_base, %{
                 text: :black,
                 background: :grey,
                 border: {84, 84, 84},
                 active: {40, 40, 40}
               })

  @scrollbar Map.merge(@flo_base, %{
               text: :black,
               background: :grey,
               border: {84, 84, 84},
               active: {40, 40, 40}
             })

  # specialty themes
  @primary Map.merge(@flo_base, %{text: :white, background: :steel_blue, active: {8, 86, 136}})
  @secondary Map.merge(@flo_base, %{background: {111, 117, 125}, active: {86, 90, 95}})
  @success Map.merge(@flo_base, %{background: {99, 163, 74}, active: {74, 123, 56}})
  @danger Map.merge(@flo_base, %{background: {191, 72, 71}, active: {164, 54, 51}})
  @warning Map.merge(@flo_base, %{background: {239, 196, 42}, active: {197, 160, 31}})
  @info Map.merge(@flo_base, %{background: {94, 159, 183}, active: {70, 119, 138}})
  @text Map.merge(@flo_base, %{text: {72, 122, 252}, background: :clear, active: :clear})

  @themes %{
    base: @flo_base,
    dark: @flo_dark,
    light: @flo_light,
    scrollbar: @scrollbar,
    primary: @flo_primary,
    secondary: @secondary,
    success: @success,
    danger: @danger,
    warning: @warning,
    info: @info,
    text: @text
  }

  @schema [:active_text]

  use Scenic.Themes, [
    [name: :scenic, themes: Scenic.Themes],
    [name: :flo_ui, themes: @themes, schema: @schema]
  ]

  def load(), do: [name: :flo_ui, themes: @themes, schema: @schema]
end
