defmodule FloUI.Tab do
  alias FloUI.Util.FontMetricsHelper

  @moduledoc ~S"""
  ## Usage in SnapFramework

  Tab should be passed into the Tabs module as follows.

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
    name: :tab,
    template: "lib/tabs/tab.eex",
    controller: FloUI.TabController,
    assigns: [
      label: nil,
      cmp: nil,
      id: nil,
      selected?: false,
      hovered?: false
    ],
    opts: []

  defcomponent(:tab, :tuple)

  watch([:hovered?])

  use_effect([assigns: [selected?: :any]],
    run: [:on_selected_change]
  )

  def setup(%{assigns: %{data: {label, cmp}, hovered?: hovered, opts: opts}} = scene) do
    # request_input(scene, [:cursor_pos])
    if opts[:selected?], do: send_parent(scene, {:tab_pid, self()})

    scene
    |> assign(
      label: label,
      width: FontMetricsHelper.get_text_width(label, 20),
      cmp: cmp,
      id: opts[:id] || "",
      selected?: opts[:selected?] || false,
      hovered?: hovered
    )
    |> get_theme
  end

  def bounds({label, _cmp}, _opts) do
    {0.0, 0.0, FontMetricsHelper.get_text_width(label, 20), 40}
  end

  def process_input({:cursor_pos, _}, :bg, scene) do
    capture_input(scene, [:cursor_pos])
    {:noreply, assign(scene, hovered?: true)}
  end

  def process_input({:cursor_pos, _}, _, scene) do
    release_input(scene)
    {:noreply, assign(scene, hovered?: false)}
  end

  def process_input({:cursor_button, {:btn_left, 1, _, _}}, _, scene) do
    send_parent_event(scene, {:select_tab, scene.assigns.cmp})
    {:noreply, assign(scene, selected?: true)}
  end

  def process_input({:cursor_button, {:btn_left, 0, _, _}}, _, scene) do
    {:noreply, scene}
  end

  def process_call({:put, value}, _, scene) do
    {:reply, :ok, assign(scene, selected?: value)}
  end

  def process_call(_, _, scene) do
    {:noreply, scene}
  end

  def get_theme(%{assigns: %{opts: opts}} = scene) do
    schema = FloUI.Themes.get_schema()
    theme = Scenic.Themes.normalize(opts[:theme]) || Scenic.Themes.normalize({:flo_ui, :dark})
    Scenic.Themes.validate(theme, schema)
    assign(scene, theme: theme)
  end
end
