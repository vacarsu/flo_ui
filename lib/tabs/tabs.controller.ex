defmodule FloUI.TabsController do
  alias Scenic.Graph
  alias Scenic.Primitive

  def on_tab_change(%{assigns: %{graph: graph, active_tab: active_tab, tabs: tabs}} = scene) do
    graph =
      Enum.reduce(tabs, graph, fn {_label, cmp}, g ->
        if cmp == active_tab do
          Graph.modify(g, cmp, &Primitive.put_style(&1, :hidden, :false))
        else
          Graph.modify(g, cmp, &Primitive.put_style(&1, :hidden, :true))
        end
      end)

    Scenic.Scene.assign(scene, graph: graph)
  end
end
