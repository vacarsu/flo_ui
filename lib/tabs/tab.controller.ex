defmodule FloUI.TabController do
  alias Scenic.Graph
  alias Scenic.Primitive

  def on_hovered_change(scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:bg, &Primitive.put_style(&1, :fill, get_bg_color(scene)))
      |> Graph.modify(:text, &Primitive.put_style(&1, :fill, get_text_color(scene)))

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_selected_change(scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:bg, &Primitive.put_style(&1, :fill, get_bg_color(scene)))
      |> Graph.modify(:text, &Primitive.put_style(&1, :fill, get_text_color(scene)))

    Scenic.Scene.assign(scene, graph: graph)
  end

  defp get_bg_color(%{assigns: %{hovered?: true}} = scene) do
    scene.assigns.theme.thumb
  end

  defp get_bg_color(%{assigns: %{hovered?: false, selected?: true}} = scene) do
    scene.assigns.theme.focus
  end

  defp get_bg_color(%{assigns: %{hovered?: false, selected?: false}} = scene) do
    scene.assigns.theme.surface
  end

  defp get_text_color(%{assigns: %{hovered?: true}} = scene) do
    scene.assigns.theme.active_text
  end

  defp get_text_color(%{assigns: %{hovered?: false, selected?: true}} = scene) do
    scene.assigns.theme.active_text
  end

  defp get_text_color(%{assigns: %{hovered?: false, selected?: false}} = scene) do
    scene.assigns.theme.text
  end
end
