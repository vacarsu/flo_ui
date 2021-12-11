defmodule FloUI.SelectionListItemController do
  alias Scenic.Graph
  alias Scenic.Primitive

  def on_selected_change(%{assigns: %{selected: true}} = scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:box, &Primitive.put_style(&1, :fill, scene.assigns.theme.surface_primary))
      |> Graph.modify(:text, &Primitive.put_style(&1, :fill, scene.assigns.theme.active_text))

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_selected_change(%{assigns: %{selected: false}} = scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:box, &Primitive.put_style(&1, :fill, scene.assigns.theme.surface))
      |> Graph.modify(:text, &Primitive.put_style(&1, :fill, scene.assigns.theme.text))

    Scenic.Scene.assign(scene, graph: graph)
  end
end
