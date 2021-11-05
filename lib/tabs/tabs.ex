defmodule FloUI.Tabs do
  alias Scenic.Graph
  alias Scenic.Primitive

  @moduledoc ~S"""
  ## Usage in SnapFramework

  The following example uses FloUI.Tabs and Grid to lay the tabs out. Iterates over the @tabs assign to render each tab.
  @module.get_tab_width runs FontMetrics on the label to get the width.

  ``` elixir
  <%= graph font_size: 20 %>

  <%= component FloUI.Tabs, {@active_tab, @tabs}, id: :tabs do %>
      <%= component FloUI.Grid, %{
          start_xy: {0, 0},
          max_xy: {@module.get_tabs_width(@tabs), 40}
      } do %>
          <%= for {{label, cmp}, i} <- Enum.with_index(@tabs) do %>
              <%= component FloUI.Tab,
                  {label, cmp},
                  selected?: if(i == 0, do: true, else: false),
                  id: :"#{label}",
                  width: @module.get_tab_width(label),
                  height: 40
              %>
          <% end %>
      <% end %>
  <% end %>
  ```
  """

  use SnapFramework.Component,
    name: :tabs,
    template: "lib/tabs/tabs.eex",
    controller: FloUI.TabsController,
    assigns: [
      active_tab: nil,
      active_pid: nil,
      tabs: nil
    ],
    opts: []

  defcomponent :tabs, :any

  use_effect [assigns: [active_tab: :any]], [
    run: [:on_tab_change]
  ]

  def setup(%{assigns: %{data: {active_tab, tabs}}} = scene) do
    scene |> assign(active_tab: active_tab, tabs: tabs)
  end

  def process_info({:tab_pid, pid}, scene) do
    {:noreply, assign(scene, active_pid: pid)}
  end

  def process_event(
    {:select_tab, cmp},
    pid,
    %{assigns: %{active_tab: active_tab, active_pid: active_pid}} = scene
  )
  when cmp != active_tab do
    GenServer.call(active_pid, {:put, false})

    scene =
      scene
      |> assign(active_tab: cmp, active_pid: pid)

    {:cont, {:select_tab, cmp}, scene}
  end

  def process_event({:select_tab, _cmp}, _pid, scene) do
    {:noreply, scene}
  end

  def process_event(event, _, scene) do
    {:cont, event, scene}
  end
end
