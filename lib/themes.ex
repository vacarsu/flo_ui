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
  {:flo_ui, :amber_light}
  {:flo_ui, :amber_dark}
  {:flo_ui, :orange_light}
  {:flo_ui, :orange_dark}
  {:flo_ui, :teal_light}
  {:flo_ui, :teal_dark}
  {:flo_ui, :green_light}
  {:flo_ui, :green_dark}
  {:flo_ui, :cyan_light}
  {:flo_ui, :cyan_dark}
  {:flo_ui, :sky_light}
  {:flo_ui, :sky_dark}
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
    focus: :steel_blue,
    danger: :red_800,
    warning: :orange_700,
    alert: :yellow_500,
    success: :green_700
  }

  @dark Map.merge(@base, %{
          text: :white,
          active_text: :white,
          background: :neutral_800,
          surface: :neutral_600,
          surface_primary: :steel_blue,
          surface_secondary: :neutral_500,
          scrollbar_surface: :neutral_700,
          scrollbar_background: :neutral_900
        })

  @light Map.merge(@base, %{
           text: :black,
           active_text: :white,
           background: :neutral_100,
           surface: :neutral_300,
           surface_primary: :steel_blue,
           surface_secondary: :neutral_200,
           scrollbar_surface: :neutral_400,
           scrollbar_background: :neutral_300
         })

  @blue_light Map.merge(@light, %{
                surface_primary: :blue_800,
                thumb: :blue_800,
                active: :blue_900,
                focus: :blue_900,
                highlight: :blue_700
              })

  @blue_dark Map.merge(@dark, %{
               surface_primary: :blue_800,
               border: :zinc_800,
               thumb: :blue_800,
               active: :blue_900,
               focus: :blue_900,
               highlight: :blue_700
             })

  @red_light Map.merge(@light, %{
               active_text: :white,
               surface_primary: :red_800,
               thumb: :red_800,
               active: :red_900,
               focus: :red_900,
               highlight: :red_600
             })

  @red_dark Map.merge(@dark, %{
              active_text: :white,
              border: :zinc_800,
              surface_primary: :red_800,
              thumb: :red_800,
              active: :red_900,
              focus: :red_900,
              highlight: :red_600
            })

  @purple_light Map.merge(@light, %{
                  surface_primary: :purple_600,
                  thumb: :purple_600,
                  active: :purple_700,
                  focus: :purple_700,
                  highlight: :purple_500
                })

  @purple_dark Map.merge(@dark, %{
                 surface_primary: :purple_600,
                 border: :zinc_800,
                 thumb: :purple_600,
                 active: :purple_700,
                 focus: :purple_700,
                 highlight: :purple_500
               })

  @amber_light Map.merge(@light, %{
                 surface_primary: :amber_300,
                 thumb: :amber_300,
                 active: :amber_400,
                 focus: :amber_400,
                 highlight: :amber_200
               })

  @amber_dark Map.merge(@dark, %{
                surface_primary: :amber_300,
                border: :zinc_800,
                thumb: :amber_300,
                active: :amber_400,
                focus: :amber_400,
                highlight: :amber_200
              })

  @orange_light Map.merge(@light, %{
                  surface_primary: :orange_300,
                  thumb: :orange_300,
                  active: :orange_400,
                  focus: :orange_400,
                  highlight: :orange_200
                })

  @orange_dark Map.merge(@dark, %{
                 surface_primary: :orange_300,
                 border: :zinc_800,
                 thumb: :orange_300,
                 active: :orange_400,
                 focus: :orange_400,
                 highlight: :orange_200
               })

  @teal_light Map.merge(@light, %{
                surface_primary: :teal_600,
                thumb: :teal_500,
                focus: :teal_600,
                active: :teal_600,
                highlight: :teal_400
              })

  @teal_dark Map.merge(@dark, %{
               surface_primary: :teal_600,
               border: :zinc_800,
               thumb: :teal_500,
               active: :teal_600,
               focus: :teal_600,
               highlight: :teal_400
             })

  @green_light Map.merge(@light, %{
                 active_text: :black,
                 surface_primary: :green_500,
                 thumb: :green_400,
                 active: :green_500,
                 focus: :green_500,
                 highlight: :green_300
               })

  @green_dark Map.merge(@dark, %{
                active_text: :black,
                border: :zinc_800,
                surface_primary: :green_500,
                thumb: :green_400,
                active: :green_500,
                focus: :green_500,
                highlight: :green_300
              })

  @cyan_light Map.merge(@light, %{
                active_text: :black,
                surface_primary: :cyan_500,
                thumb: :cyan_400,
                active: :cyan_500,
                focus: :cyan_500,
                highlight: :cyan_300
              })

  @cyan_dark Map.merge(@dark, %{
               active_text: :black,
               border: :zinc_800,
               surface_primary: :cyan_500,
               thumb: :cyan_400,
               active: :cyan_500,
               focus: :cyan_500,
               highlight: :cyan_300
             })

  @sky_light Map.merge(@light, %{
               active_text: :black,
               surface_primary: :sky_500,
               thumb: :sky_400,
               active: :sky_500,
               focus: :sky_500,
               highlight: :sky_300
             })

  @sky_dark Map.merge(@dark, %{
              active_text: :black,
              border: :zinc_800,
              surface_primary: :sky_500,
              thumb: :sky_400,
              active: :sky_500,
              focus: :sky_500,
              highlight: :sky_300
            })

  @emerald_light Map.merge(@light, %{
                   active_text: :black,
                   surface_primary: :emerald_500,
                   thumb: :emerald_400,
                   active: :emerald_500,
                   focus: :emerald_500,
                   highlight: :emerald_300
                 })

  @emerald_dark Map.merge(@dark, %{
                  active_text: :black,
                  border: :zinc_800,
                  surface_primary: :emerald_500,
                  thumb: :emerald_400,
                  active: :emerald_500,
                  focus: :emerald_500,
                  highlight: :emerald_300
                })

  @yellow_light Map.merge(@light, %{
                  active_text: :black,
                  surface_primary: :yellow_300,
                  thumb: :yellow_300,
                  active: :yellow_400,
                  focus: :yellow_400,
                  highlight: :yellow_200
                })

  @yellow_dark Map.merge(@dark, %{
                 active_text: :black,
                 surface_primary: :yellow_300,
                 border: :zinc_800,
                 thumb: :yellow_300,
                 active: :yellow_400,
                 focus: :yellow_400,
                 highlight: :yellow_200
               })

  @themes %{
    base: @base,
    dark: @dark,
    light: @light,
    blue_light: @blue_light,
    blue_dark: @blue_dark,
    red_light: @red_light,
    red_dark: @red_dark,
    purple_light: @purple_light,
    purple_dark: @purple_dark,
    amber_light: @amber_light,
    amber_dark: @amber_dark,
    orange_light: @orange_light,
    orange_dark: @orange_dark,
    teal_light: @teal_light,
    teal_dark: @teal_dark,
    green_light: @green_light,
    green_dark: @green_dark,
    cyan_light: @cyan_light,
    cyan_dark: @cyan_dark,
    sky_light: @sky_light,
    sky_dark: @sky_dark,
    emerald_light: @emerald_light,
    emerald_dark: @emerald_dark,
    yellow_light: @yellow_light,
    yellow_dark: @yellow_dark
  }

  @schema [
    :active_text,
    :surface,
    :surface_primary,
    :surface_secondary,
    :scrollbar_surface,
    :scrollbar_background,
    :danger,
    :warning,
    :alert,
    :success
  ]

  @lib [name: :flo_ui, themes: @themes, schema: @schema, palette: FloUI.Palette.get()]

  use Scenic.Themes, [
    [name: :scenic, themes: Scenic.Themes],
    @lib
  ]

  def load(), do: @lib

  def get_schema(), do: @schema
end
