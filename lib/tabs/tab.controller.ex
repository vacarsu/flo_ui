defmodule FloUI.TabController do
  alias Scenic.Graph
  alias Scenic.Primitive

  def on_selected_change(%{assigns: %{selected?: true, theme: theme}} = scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:bg, &Primitive.put_style(&1, :fill, theme.surface_primary))
      |> Graph.modify(:text, &Primitive.put_style(&1, :fill, theme.active_text))

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_selected_change(%{assigns: %{selected?: false, theme: theme}} = scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:bg, &Primitive.put_style(&1, :fill, theme.surface))
      |> Graph.modify(:text, &Primitive.put_style(&1, :fill, theme.text))

    Scenic.Scene.assign(scene, graph: graph)
  end
end
