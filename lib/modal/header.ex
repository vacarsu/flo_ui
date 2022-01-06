defmodule FloUI.Modal.Header do
  @moduledoc false

  use SnapFramework.Component,
    name: :modal_header,
    template: "lib/modal/header.eex",
    controller: :none,
    assigns: [
      width: 500,
      height: 500,
      show_check: true,
      show_close: true
    ],
    opts: []

  defcomponent(:modal_header, :string)

  @impl true
  def setup(%{assigns: %{opts: opts}} = scene) do
    assign(scene,
      width: opts[:width] || 500,
      height: opts[:height] || 500,
      show_check: opts[:show_check] || false,
      show_close: opts[:show_close] || false
    )
    |> get_theme
  end

  @impl true
  def handle_get(_from, scene) do
    {:reply, scene, scene}
  end

  def get_theme(%{assigns: %{opts: opts}} = scene) do
    schema = FloUI.Themes.get_schema()
    theme = Scenic.Themes.normalize(opts[:theme]) || Scenic.Themes.normalize({:flo_ui, :dark})
    Scenic.Themes.validate(theme, schema)
    assign(scene, theme: theme)
  end
end
