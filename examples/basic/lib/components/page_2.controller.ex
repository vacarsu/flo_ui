defmodule Basic.Component.Page2Controller do
  import FloUI.TextInput, only: [text_input: 3]
  alias Scenic.Graph

  def on_input_change(scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:text_input, &text_input(&1, scene.assigns.input_value, []))

    Scenic.Scene.assign(scene, graph: graph)
  end
end
