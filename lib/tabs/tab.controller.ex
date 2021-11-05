defmodule FloUI.TabController do
  alias Scenic.Graph
  alias Scenic.Primitive

  def on_selected_change(%{assigns: %{selected?: true}} = scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:bg, &Primitive.put_style(&1, :fill, :steel_blue))
      |> Graph.modify(:text, &Primitive.put_style(&1, :fill, :white))

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_selected_change(%{assigns: %{selected?: false}} = scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:bg, &Primitive.put_style(&1, :fill, :gainsboro))
      |> Graph.modify(:text, &Primitive.put_style(&1, :fill, :black))

    Scenic.Scene.assign(scene, graph: graph)
  end
end
