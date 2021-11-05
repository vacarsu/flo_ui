defmodule FloUI.Icon.Button do
  @moduledoc """
  ## Usage in SnapFramework

  Render a button with an icon.

  data is a string for the tooltip.

  ``` elixir
  <%= component FloUI.Icon.Button,
      "tooltip text",
      id: :btn_icon
  do %>
    <%= component FloUI.Icon,
        {:flo_ui, "path_to_icon"}
    %>
  <% end %>
  ```
  """

  use SnapFramework.Component,
    name: :icon_button,
    template: "lib/icons/icon_button/icon_button.eex",
    controller: FloUI.Icon.ButtonController,
    assigns: [
      id: nil,
      icon: nil,
      label: nil,
      showing_highlight: false,
      showing_tooltip: false
    ],
    opts: []

    defcomponent :icon_button, :any

    watch [:children]

    use_effect [assigns: [showing_highlight: :any]], [
      run: [:on_highlight_change]
    ]

    use_effect [assigns: [showing_tooltip: :any]], [
      run: [:on_show_tooltip_change]
    ]

    # DEPRECATED
    # use_effect [on_click: [@assigns[:id]]], :cont, []

    @impl true
    def setup(%{assigns: %{data: nil}} = scene) do
      # Logger.debug(inspect state, pretty: true)
      scene |> assign(id: scene.assigns.opts[:id] || nil)
    end

    @impl true
    def setup(%{assigns: %{data: label}} = scene) do
      request_input(scene, [:cursor_pos])
      scene |> assign(id: scene.assigns.opts[:id] || nil, label: label)
    end

    @impl true
    def process_update(data, opts, scene) do
      {:noreply, assign(scene, data: data, children: opts[:children], opts: opts)}
    end

    @impl true
    def process_input({:cursor_button, {:btn_left, 1, _, _}}, :btn, scene) do
      {:noreply, scene}
    end

    @impl true
    def process_input({:cursor_button, {:btn_left, 0, _, _}}, :btn, scene) do
      send_parent_event(scene, {:click, scene.assigns.id})
      {:noreply, scene}
    end

    @impl true
    def process_input({:cursor_pos, _}, :btn,  %{assigns: %{label: nil}} = scene) do
      capture_input(scene, [:cursor_pos])
      {:noreply, assign(scene, showing_highlight: true, showing_tooltip: false)}
    end

    @impl true
    def process_input({:cursor_pos, _}, :btn,  scene) do
      capture_input(scene, [:cursor_pos])
      {:noreply, assign(scene, showing_highlight: true, showing_tooltip: true)}
    end

    @impl true
    def process_input({:cursor_pos, _}, _,  scene) do
      release_input(scene)
      {:noreply, assign(scene, showing_highlight: false, showing_tooltip: false)}
    end

    @impl true
    def process_input(_event, _, scene) do
      {:noreply, scene}
    end
end
