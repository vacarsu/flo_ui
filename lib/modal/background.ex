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

  @default_theme Scenic.Themes.preset({:flo_ui, :dark})

  use SnapFramework.Component,
    name: :background,
    template: "lib/modal/background.eex",
    controller: :none,
    assigns: [width: 0, height: 0],
    opts: []

  defcomponent(:background, :any)

  def setup(%{assigns: %{opts: opts}} = scene) do
    assign(scene, theme: get_theme(opts))
  end

  defp get_theme(opts) do
    case opts[:theme] do
      nil -> @default_theme
      :dark -> @default_theme
      :light -> @default_theme
      theme -> theme
    end
    |> Scenic.Themes.normalize()
  end
end
