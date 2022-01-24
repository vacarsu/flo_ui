defmodule FloUI.TabsController do
  import FloUI.Tab, only: [tab: 3]
  alias Scenic.Graph
  alias Scenic.Primitive
  require Logger

  def on_tab_change(%{assigns: %{graph: graph, active_tab: active_tab, tabs: tabs}} = scene) do
    graph =
      Enum.reduce(tabs, graph, fn {_label, cmp}, g ->
        if cmp == active_tab do
          Graph.modify(g, cmp, &Primitive.put_style(&1, :hidden, false))
        else
          Graph.modify(g, cmp, &Primitive.put_style(&1, :hidden, true))
        end
      end)

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_tab_to_disable_change(scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(scene.assigns.tab_to_disable, &tab(&1, {scene.assigns.tab_to_disable, FloDcs.Component.Widgets}, disabled?: true))

    Scenic.Scene.assign(scene, graph: graph, tab_to_disable: nil)
  end

  def on_tab_to_enable_change(scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(scene.assigns.tab_to_disable, &tab(&1, {scene.assigns.tab_to_disable, FloDcs.Component.Widgets}, disabled?: false))

    Scenic.Scene.assign(scene, graph: graph, tab_to_enable: nil)
  end
end
