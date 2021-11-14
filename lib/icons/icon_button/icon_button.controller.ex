defmodule FloUI.Icon.ButtonController do
  @moduledoc """
  Controller for FloUI.Icon.Button
  """

  alias Scenic.Graph
  alias Scenic.Primitive
  alias FloUI.Theme

  @theme Theme.preset(:dark)

  def on_highlight_change(%{assigns: %{showing_highlight: true}} = scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:bg, &Primitive.put_style(&1, :fill, @theme.active))

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_highlight_change(%{assigns: %{showing_highlight: false}} = scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:bg, &Primitive.put_style(&1, :fill, :clear))

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_show_tooltip_change(scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(
        :tooltip,
        &Primitive.put_style(&1, :hidden, not scene.assigns.showing_tooltip)
      )

    Scenic.Scene.assign(scene, graph: graph)
  end
end
