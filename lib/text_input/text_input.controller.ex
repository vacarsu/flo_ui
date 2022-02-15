defmodule FloUI.Component.TextInputController do
  import Scenic.Components, only: [text_field: 3]

  alias Scenic.Graph
  alias Scenic.Primitive

  def on_disabled_change(%{assigns: %{disabled?: disabled?}} = scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:rrect_disabled, &Primitive.put_style(&1, :hidden, not disabled?))

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_data_change(scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(scene.assigns.id, &text_field(&1, scene.assigns.data, []))

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_clear_hidden_change(%{assigns: %{clear_hidden: hidden?}} = scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:btn_clear, &Primitive.put_style(&1, :hidden, hidden?))

    Scenic.Scene.assign(scene, graph: graph)
  end
end
