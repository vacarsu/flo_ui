defmodule FloUI.Dropdown.ItemController do
  alias Scenic.Graph
  alias Scenic.Primitive

  def on_hovered_change(scene) do
    graph =
      case scene.assigns.hovered do
        false ->
          scene.assigns.graph |> Graph.modify(:bg, &Primitive.put_style(&1, :fill, scene.assigns.theme.background))
        true ->
          scene.assigns.graph |> Graph.modify(:bg, &Primitive.put_style(&1, :fill, scene.assigns.theme.thumb))
      end

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_selected_change(scene) do
    graph =
      case scene.assigns.selected do
        false ->
          scene.assigns.graph |> Graph.modify(:bg, &Primitive.put_style(&1, :fill, scene.assigns.theme.background))
        true ->
          scene.assigns.graph |> Graph.modify(:bg, &Primitive.put_style(&1, :fill, scene.assigns.theme.thumb))
      end

    Scenic.Scene.assign(scene, graph: graph)
  end
end
