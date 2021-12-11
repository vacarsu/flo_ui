defmodule FloUI.Tooltip do
  alias FloUI.Util.FontMetricsHelper

  @moduledoc """
  ## Usage in SnapFramework

  Renders a tooltip.

  ``` elixir
  <%= component FloUI.Tooltip,
      @label,
      id: :tooltip
  %>
  ```
  """

  use SnapFramework.Component,
    name: :tooltip,
    template: "lib/tooltip/tooltip.eex",
    controller: :none,
    assigns: [width: 0, height: 0],
    opts: []

  defcomponent(:tooltip, :string)

  def setup(scene) do
    scene
    |> get_background_width
    |> get_background_height
    |> get_theme
  end

  def bound(data, _opts) do
    {0.0, 0.0, FontMetricsHelper.get_text_width(data, 20), FontMetricsHelper.get_text_height(20)}
  end

  def get_background_width(%{assigns: %{data: data}} = scene) do
    assign(scene, width: FontMetricsHelper.get_text_width(data, 20))
  end

  def get_background_height(scene) do
    assign(scene, height: FontMetricsHelper.get_text_height(20))
  end

  def get_theme(%{assigns: %{opts: opts}} = scene) do
    schema = FloUI.Themes.get_schema()
    theme = Scenic.Themes.normalize(opts[:theme]) || Scenic.Themes.normalize({:flo_ui, :dark})
    Scenic.Themes.validate(theme, schema)
    assign(scene, theme: theme)
  end
end
