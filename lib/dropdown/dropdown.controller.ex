defmodule FloUI.DropdownController do
  import Scenic.Primitives, only: [text: 3]
  alias Scenic.Graph
  alias Scenic.Primitive

  def on_open_change(scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:bg, &Primitive.put_style(&1, :stroke, get_border_color(scene)))
      |> Graph.modify(:dropdown_bg, &Primitive.put_style(&1, :stroke, get_border_color(scene)))
      |> Graph.modify(:scroll_container, &Primitive.put_style(&1, :hidden, not scene.assigns.open?))
      |> Graph.modify(:dropdown_bg, &Primitive.put_style(&1, :hidden, not scene.assigns.open?))
      |> Graph.modify(:border_cover, &Primitive.put_style(&1, :hidden, not scene.assigns.open?))
      |> Graph.modify(:clickout, &Primitive.put_style(&1, :hidden, not scene.assigns.open?))
      |> Graph.modify(:icon, &Primitive.put_style(&1, :rotate, if(not scene.assigns.open?, do: 0, else: :math.pi())))

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_selected_change(scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:selected_label, &text(&1, scene.assigns.selected_label, []))

    Scenic.Scene.assign(scene, graph: graph)
  end

  defp get_border_color(scene) do
    case scene.assigns.open? do
      true -> {1, {scene.assigns.theme.focus, 150}}
      false -> {1, {scene.assigns.theme.border, 150}}
    end
  end
end
