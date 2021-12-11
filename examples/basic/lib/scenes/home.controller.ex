defmodule Basic.Scene.HomeController do
  alias Scenic.ViewPort

  def on_theme_change(%{assigns: %{active_theme: active_theme}} = scene) do
    ViewPort.set_theme(scene.viewport, active_theme)
    scene
  end
end
