defmodule FloUI.Modal.Background do
  @moduledoc """
  ## Usage in SnapFramework

  Render this behind a modal if you want to block input to primitive render under it.

  ``` elixir
  <%= component FloUI.Modal.Background,
      nil,
      id: :modal_background
  %>
  ```
  """

  use SnapFramework.Component,
    name: :background,
    template: "lib/modal/background.eex",
    controller: :none,
    assigns: [width: 0, height: 0],
    opts: []

  defcomponent(:background, :any)

  @impl true
  def setup(scene) do
    scene |> get_theme
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
