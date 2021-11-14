defmodule FloUI.Dropdown do
  @moduledoc """
  ## Usage in SnapFramework

  Dropdown component that scrolls. You can pass two separate themes as options. one for the dropdown, and one for the scroll bar.

  Options
  ``` elixir
  theme,
  scroll_bar_theme
  ```

  data is a tuple in the form of

  ``` elixir
  {
    [
      {{"option 1", :option_1}, :option_1},
      {{"option 2", :option_2}, :option_2},
      {{"option 3", :option_3}, :option_3}
    ],
    :option_1
  }
  ```

  Events emitted

  `{:value_changed, id, value}`

  ``` elixir
  <%= component FloUI.Dropdown,
      {@items, @selected},
      id: :dropdown,
      theme: @theme,
      scroll_bar_theme: @scroll_bar_theme
  %>
  ```
  """
  @default_height 100
  @default_max_height 300
  @default_theme FloUI.Theme.preset(:base)

  alias FloUI.Dropdown.Items

  use SnapFramework.Component,
    name: :dropdown,
    template: "lib/dropdown/dropdown.eex",
    controller: FloUI.DropdownController,
    assigns: [],
    opts: []

  defcomponent(:dropdown, :tuple)

  use_effect [assigns: [open?: :any]], [
    run: [:on_open_change]
  ]

  use_effect [assigns: [selected_label: :any]], [
    run: [:on_selected_change]
  ]

  def setup(%{assigns: %{data: {items, selected} = data, opts: opts}} = scene) do
    assign(scene,
      items: items,
      selected_label: "",
      selected_key: nil,
      selected: selected,
      open?: false,
      width: get_width(data, opts),
      height: opts[:height] || @default_height,
      max_height: opts[:max_height] || @default_max_height,
      frame_height: get_frame_height(data, opts),
      content_height: get_content_height(items),
      theme: opts[:theme] || @default_theme
    )
  end

  def bounds(data, opts) do
    {0.0, 0.0, get_width(data, opts), opts[:height] || @default_height}
  end

  def process_event({:value_changed, {{label, value}, key}}, _, scene) do
    {:cont, {:value_changed, scene.assigns.opts[:id], value}, assign(scene, selected_label: label, selected_key: key, open?: false)}
  end

  def process_input({:cursor_button, {:btn_left, 0, _, _}}, :bg, %{assigns: %{open?: open?}} = scene) do
    {:noreply, assign(scene, open?: not open?)}
  end

  def process_input({:cursor_button, {:btn_left, 1, _, _}}, :clickout, %{assigns: %{open?: open?}} = scene) do
    {:noreply, assign(scene, open?: not open?)}
  end

  def process_input(_, _, scene) do
    {:noreply, scene}
  end

  defp get_width(data, opts) do
    {_, _, w, _h} = Items.bounds(data, opts)
    w
  end

  defp get_frame_height(data, opts) do
    {_, _, _w, h} = Items.bounds(data, opts)
    h
  end

  defp get_content_height(items) do
    Items.get_content_height(items)
  end
end
