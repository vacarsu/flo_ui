defmodule Basic.Component.Page1Controller do
  import Scenic.Components, only: [button: 3]
  import Scenic.Primitives, only: [text: 3]
  import FloUI.Scrollable.Container, only: [scrollable_container: 3]
  alias Scenic.Graph

  def on_btn_text_change(scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:btn_update, &button(&1, scene.assigns.btn_text, []))
      |> Graph.modify(:scrollable, &scrollable_container(&1,
        %{
            frame: {400, 500},
            content: {800, 800},
            scroll_position: {100, 50}
        }, [])
      )

    Scenic.Scene.assign(scene, graph: graph)
  end
end
