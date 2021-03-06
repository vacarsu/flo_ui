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

  @default_theme FloUI.Theme.preset(:primary)

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

  defcomponent(:icon_button, :any)

  watch([:children])

  use_effect([assigns: [showing_highlight: :any]],
    run: [:on_highlight_change]
  )

  use_effect([assigns: [showing_tooltip: :any]],
    run: [:on_show_tooltip_change]
  )

  # DEPRECATED
  # use_effect [on_click: [@assigns[:id]]], :cont, []

  @impl true
  def setup(%{assigns: %{data: nil, opts: opts}} = scene) do
    scene
    |> assign(
      id: scene.assigns.opts[:id] || nil,
      theme: get_theme(opts)
    )
  end

  def setup(%{assigns: %{data: label, opts: opts}} = scene) do
    # request_input(scene, [:cursor_pos])
    scene
    |> assign(
      id: scene.assigns.opts[:id] || nil,
      label: label,
      theme: get_theme(opts)
    )
  end

  @impl true
  def bounds(_data, _opts) do
    {0.0, 0.0, 50, 50}
  end

  @impl true
  def process_update(data, opts, scene) do
    {:noreply, assign(scene, data: data, children: opts[:children], opts: opts)}
  end

  @impl true
  def process_input({:cursor_button, {:btn_left, 1, _, _}}, :btn, scene) do
    {:noreply, scene}
  end

  def process_input({:cursor_button, {:btn_left, 0, _, _}}, :btn, scene) do
    send_parent_event(scene, {:click, scene.assigns.id})
    {:noreply, scene}
  end

  def process_input({:cursor_pos, _}, :btn, %{assigns: %{label: nil}} = scene) do
    capture_input(scene, [:cursor_pos])
    {:noreply, assign(scene, showing_highlight: true, showing_tooltip: false)}
  end

  def process_input({:cursor_pos, _}, :btn, scene) do
    capture_input(scene, [:cursor_pos])
    {:noreply, assign(scene, showing_highlight: true, showing_tooltip: true)}
  end

  def process_input({:cursor_pos, _}, _, scene) do
    release_input(scene)
    {:noreply, assign(scene, showing_highlight: false, showing_tooltip: false)}
  end

  def process_input(_event, _, scene) do
    {:noreply, scene}
  end

  defp get_theme(opts) do
      case opts[:theme] do
        nil -> @default_theme
        :dark -> @default_theme
        :light -> @default_theme
        theme -> theme
      end
      |> FloUI.Theme.normalize()
  end
end
