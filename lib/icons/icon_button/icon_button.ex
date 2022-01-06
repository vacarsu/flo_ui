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
      pressed: false,
      showing_highlight: false,
      showing_tooltip: false
    ],
    opts: []

  defcomponent(:icon_button, :string)

  watch([:children])

  use_effect([assigns: [showing_highlight: :any]],
    run: [:on_highlight_change]
  )

  use_effect([assigns: [showing_tooltip: :any]],
    run: [:on_show_tooltip_change]
  )

  @impl true
  def setup(%{assigns: %{data: nil}} = scene) do
    scene
    |> assign(
      id: scene.assigns.opts[:id] || nil
    )
    |> get_theme
  end

  def setup(%{assigns: %{data: label}} = scene) do
    # request_input(scene, [:cursor_pos])
    scene
    |> assign(
      id: scene.assigns.opts[:id] || nil,
      label: label
    )
    |> get_theme
  end

  @impl true
  def bounds(_data, _opts) do
    {0.0, 0.0, 50, 50}
  end

  @impl true
  def handle_get(_from, scene) do
    {:reply, scene, scene}
  end

  @impl true
  def process_update(data, opts, scene) do
    {:noreply, assign(scene, data: data, children: opts[:children], opts: opts)}
  end

  @impl true
  def process_input({:cursor_button, {:btn_left, 1, _, _}}, :btn, scene) do
    capture_input(scene, [:cursor_button])
    {:noreply, assign(scene, pressed: true)}
  end

  def process_input({:cursor_button, {:btn_left, 0, _, _}}, :btn, %{assigns: %{pressed: true}} = scene) do
    send_parent_event(scene, {:click, scene.assigns.id})
    {:noreply, assign(scene, pressed: false)}
  end

  def process_input({:cursor_button, {:btn_left, 0, _, _}}, nil, scene) do
    {:noreply, assign(scene, pressed: false)}
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

  def get_theme(%{assigns: %{opts: opts}} = scene) do
    schema = FloUI.Themes.get_schema()
    theme = Scenic.Themes.normalize(opts[:theme]) || Scenic.Themes.normalize({:flo_ui, :dark})
    Scenic.Themes.validate(theme, schema)
    assign(scene, theme: theme)
  end
end
