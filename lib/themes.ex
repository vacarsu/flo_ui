defmodule FloUI.Themes do
  @moduledoc """
  ## Usage

  To use the FloUI themes do method 1 if you're not loading any of your own scenic themes. If you have your own themes you want to load, do method 2.

  1. Use only the Scenic and FloUI themes
  In your config put the following

  ``` elixir
  config :scenic, :themes, module: FloUI.Themes
  ```

  2. Use my own custom themes plus FloUI and Scenic themes.
  Create a MyApp.Themes module.
  There is no need to define the custom schema or palette for FloUI.
  Scenic will load those in from the module for you.

  ``` elixir
  defmodule MyApp.Themes do
    @lib [name: :my_app, themes: @my_themes, schema: @my_custom_schema, palette: @my_custom_palette]

    use Scenic.Themes, [
      [name: :scenic, themes: Scenic.Themes],
      [name: :flo_ui, themes: FloUI.Themes]
      @lib
    ]

    def load(), do: @lib
  end
  ```

  FloUI provides several themes out of the box that work with all components.
  Below is a list of provided themes

  ``` elixir
  {:flo_ui, :base}
  {:flo_ui, :light}
  {:flo_ui, :dark}
  {:flo_ui, :scrollbar}
  {:flo_ui, :blue_light}
  {:flo_ui, :blue_dark}
  {:flo_ui, :red_light}
  {:flo_ui, :red_dark}
  {:flo_ui, :purple_light}
  {:flo_ui, :purple_dark}
  {:flo_ui, :orange_light}
  {:flo_ui, :orange_dark}
  {:flo_ui, :teal_light}
  {:flo_ui, :teal_dark}
  {:flo_ui, :green_light}
  {:flo_ui, :green_dark}
  {:flo_ui, :emerald_light}
  {:flo_ui, :emerald_dark}
  {:flo_ui, :yellow_light}
  {:flo_ui, :yellow_dark}
  ```

  You can also create your own themes to create your own look and feel.
  FloUI themes use the following schema.

  `[:active_text, :surface, :surface_primary, :surface_secondary]`
  """

  @base %{
    text: :white,
    active_text: :black,
    background: :neutral_800,
    highlight: :white,
    border: :neutral_200,
    thumb: :steel_blue,
    active: :steel_blue,
    focus: :steel_blue
  }

  @dark Map.merge(@base, %{
    text: :white,
    active_text: :white,
    background: :neutral_800,
    surface: :neutral_600,
    surface_primary: :steel_blue,
    surface_secondary: :neutral_500
  })

  @light Map.merge(@base, %{
    text: :black,
    active_text: :white,
    background: :neutral_200,
    surface: :neutral_300,
    surface_primary: :steel_blue,
    surface_secondary: :neutral_100
  })

  @scrollbar Map.merge(@base, %{
    text: :black,
    background: :grey,
    border: :flo_medium_grey,
    active: :flo_dark_grey,
    active_text: :white
  })

  @blue_light Map.merge(@light, %{
    surface_primary: :blue_800,
    thumb: :blue_800,
    focus: :blue_900
  })

  @blue_dark Map.merge(@dark, %{
    surface_primary: :blue_800,
    thumb: :blue_800,
    focus: :blue_900
  })

  @red_light Map.merge(@light, %{
    active_text: :white,
    surface_primary: :red_800,
    thumb: :red_800,
    focus: :red_900
  })

  @red_dark Map.merge(@dark, %{
    active_text: :white,
    surface_primary: :red_800,
    thumb: :red_800,
    focus: :red_900
  })

  @purple_light Map.merge(@light, %{
    surface_primary: :purple_600,
    thumb: :purple_600,
    focus: :purple_700
  })

  @purple_dark Map.merge(@dark, %{
    surface_primary: :purple_600,
    thumb: :purple_600,
    focus: :purple_700
  })

  @orange_light Map.merge(@light, %{
    surface_primary: :orange_300,
    thumb: :orange_300,
    focus: :orange_400
  })

  @orange_dark Map.merge(@dark, %{
    surface_primary: :orange_300,
    thumb: :orange_300,
    focus: :orange_400
  })

  @teal_light Map.merge(@light, %{
    surface_primary: :teal_600,
    thumb: :teal_500,
    focus: :teal_600,
    highlight: :teal_400
  })

  @teal_dark Map.merge(@dark, %{
    surface_primary: :teal_600,
    thumb: :teal_500,
    focus: :teal_600,
    highlight: :teal_400
  })

  @green_light Map.merge(@light, %{
    active_text: :black,
    surface_primary: :green_500,
    thumb: :green_400,
    focus: :green_500
  })

  @green_dark Map.merge(@dark, %{
    active_text: :black,
    surface_primary: :green_500,
    thumb: :green_400,
    focus: :green_500
  })

  @emerald_light Map.merge(@light, %{
    active_text: :black,
    surface_primary: :emerald_500,
    thumb: :emerald_400,
    focus: :emerald_500
  })

  @emerald_dark Map.merge(@dark, %{
    active_text: :black,
    surface_primary: :emerald_500,
    thumb: :emerald_400,
    focus: :emerald_500
  })

  @yellow_light Map.merge(@light, %{
    active_text: :black,
    surface_primary: :yellow_300,
    thumb: :yellow_300,
    focus: :yellow_400
  })

  @yellow_dark Map.merge(@dark, %{
    active_text: :black,
    surface_primary: :yellow_300,
    thumb: :yellow_300,
    focus: :yellow_400
  })

  @themes %{
    base: @base,
    dark: @dark,
    light: @light,
    scrollbar: @scrollbar,
    blue_light: @blue_light,
    blue_dark: @blue_dark,
    red_light: @red_light,
    red_dark: @red_dark,
    purple_light: @purple_light,
    purple_dark: @purple_dark,
    orange_light: @orange_light,
    orange_dark: @orange_dark,
    teal_light: @teal_light,
    teal_dark: @teal_dark,
    green_light: @green_light,
    green_dark: @green_dark,
    emerald_light: @emerald_light,
    emerald_dark: @emerald_dark,
    yellow_light: @yellow_light,
    yellow_dark: @yellow_dark
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
