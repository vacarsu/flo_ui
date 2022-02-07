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
    type: :string,
    template: "lib/tooltip/tooltip.eex",
    controller: :none,
    assigns: [width: 0, height: 0],
    opts: []

  @impl true
  def setup(scene) do
    scene
    |> get_background_width
    |> get_background_height
    |> get_theme
  end

  @impl true
  def bounds(data, _opts) do
    {0.0, 0.0, FontMetricsHelper.get_text_width(data, 20), FontMetricsHelper.get_text_height(20)}
  end

  @impl true
  def handle_get(_from, scene) do
    {:reply, scene, scene}
  end

  def get_background_width(%{assigns: %{data: data}} = scene) do
    assign(scene, width: FontMetricsHelper.get_text_width(data, 20))
  end

  def get_background_height(scene) do
    assign(scene, height: FontMetricsHelper.get_text_height(20))
  end

  def get_theme(%{assigns: %{opts: opts}} = scene) do
    schema = FloUI.Themes.get_schema()
    case Scenic.Themes.validate(opts[:theme], schema) do
      {:ok, theme} -> assign(scene, theme: theme)
      {:error, _msg} -> assign(scene, theme: Scenic.Themes.normalize({:flo_ui, :dark}))
    end
  end
end
