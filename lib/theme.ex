# defmodule Scenic.Themes do
#   @moduledoc """
#   Basic theme for sets for FloUI

#   ``` elixir
#   :base,
#   :dark,
#   :light,
#   :primary,
#   {:flo_ui, :scrollbar},
#   :secondary,
#   :success,
#   :danger,
#   :warning,
#   :info,
#   :text
#   ```

#   Pick a preset

#   ``` elixir
#   Scenic.Themes.preset(:primary)
#   ```

#   """

#   alias Scenic.Primitive.Style.Paint.Color

#   @flo_base %{
#     text: :white,
#     active_text: :black,
#     background: {64, 64, 64},
#     highlight: :white,
#     border: :light_grey,
#     active: :steel_blue,
#     thumb: :steel_blue,
#     focus: :steel_blue,
#     active_text: :black
#   }

#   @flo_dark Map.merge(@flo_base, %{background: :black})
#   @flo_light Map.merge(@flo_base, %{text: :black, active_text: :white, background: :gainsboro})

#   # @flo_primary Map.merge(@flo_base, %{
#   #                text: :black,
#   #                background: :grey,
#   #                border: {84, 84, 84},
#   #                active: {40, 40, 40}
#   #              })

#   @scrollbar Map.merge(@flo_base, %{
#                text: :black,
#                active_text: :black,
#                background: :grey,
#                border: {84, 84, 84},
#                active: {40, 40, 40}
#              })

#   # specialty themes
#   @primary Map.merge(@flo_base, %{text: :white, active_text: :black, background: :steel_blue, active: {8, 86, 136}})
#   @secondary Map.merge(@flo_base, %{background: {111, 117, 125}, active_text: :black, active: {86, 90, 95}})
#   @success Map.merge(@flo_base, %{background: {99, 163, 74}, active_text: :black, active: {74, 123, 56}})
#   @danger Map.merge(@flo_base, %{background: {191, 72, 71}, active_text: :black, active: {164, 54, 51}})
#   @warning Map.merge(@flo_base, %{background: {239, 196, 42}, active_text: :black, active: {197, 160, 31}})
#   @info Map.merge(@flo_base, %{background: {94, 159, 183}, active_text: :black, active: {70, 119, 138}})
#   @text Map.merge(@flo_base, %{text: {72, 122, 252}, active_text: :black, background: :clear, active: :clear})

#   @themes %{
#     base: @flo_base,
#     dark: @flo_dark,
#     light: @flo_light,
#     scrollbar: @scrollbar,
#     primary: @primary,
#     secondary: @secondary,
#     success: @success,
#     danger: @danger,
#     warning: @warning,
#     info: @info,
#     text: @text
#   }

#   # ============================================================================
#   # data verification and serialization

#   # --------------------------------------------------------
#   @doc false
#   def info(data),
#     do: """
#       #{IO.ANSI.red()}#{__MODULE__} data must either a preset theme or a map of named colors
#       #{IO.ANSI.yellow()}Received: #{inspect(data)}

#       The predefined themes are:
#       :dark, :light, :primary, :secondary, :success, :danger, :warning, :info, :text

#       If you pass in a map of colors, the common ones used in the controls are:
#       :text, :background, :border, :active, :thumb, :focus

#       #{IO.ANSI.default_color()}
#     """

#   # --------------------------------------------------------
#   @doc false
#   def validate(name) when is_atom(name), do: Map.has_key?(@themes, name)

#   def validate(custom) when is_map(custom) do
#     Enum.all?(custom, fn {_, color} -> Color.verify(color) end)
#   end

#   def validate(_), do: false

#   # --------------------------------------------------------
#   @doc false
#   def normalize(theme) when is_atom(theme), do: Map.get(@themes, theme)
#   def normalize(theme) when is_map(theme), do: theme

#   # --------------------------------------------------------
#   @doc false
#   def default(), do: Map.get(@themes, :base)

#   # --------------------------------------------------------
#   @doc false
#   def preset(theme), do: Map.get(@themes, theme)
# end
