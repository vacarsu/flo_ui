defmodule FloUI.Dropdown do
  @moduledoc """
  ## Usage in SnapFramework

  Dropdown component that scrolls. You can pass two separate themes as options. one for the dropdown, and one for the scroll bar.

  Options
  ``` elixir
  theme: theme,
  scroll_bar: %{
    show: true,
    show_buttons: true,
    theme: Scenic.Primitive.Style.Theme.preset(:dark),
    thickness: 15
  }
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
      scroll_bar: %{
        show: true,
        show_buttons: true,
        theme: Scenic.Primitive.Style.Theme.preset(:dark),
        thickness: 15
      }
  %>
  ```
  """
  @default_height 50
  @default_frame_height 300
  @default_scroll_bar %{
    show: true,
    show_buttons: true,
    theme: Scenic.Themes.preset({:flo_ui, :scrollbar}),
    thickness: 15
  }

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

  @impl true
  def setup(%{assigns: %{data: {items, selected} = data, opts: opts}} = scene) do
    width = get_width(data, opts)
    frame_height = get_frame_height(data, opts)
    content_height = get_content_height(items)
    scroll_bar = opts[:scroll_bar] || @default_scroll_bar
    show_vertical_scroll = content_height > frame_height and scroll_bar.show

    assign(scene,
      items: items,
      selected_label: "",
      selected_key: nil,
      selected: selected,
      open?: false,
      button_width: if(show_vertical_scroll, do: width + 20, else: width),
      button_height: opts[:height] || @default_height,
      background_height: frame_height + 20,
      frame_width: if(show_vertical_scroll, do: width, else: width),
      frame_height: frame_height,
      content_height: content_height,
      scroll_bar: scroll_bar,
      show_vertical_scroll: show_vertical_scroll
    )
    |> get_theme
  end

  @impl true
  def bounds(data, opts) do
    {0.0, 0.0, get_width(data, opts), opts[:height] || @default_height}
  end

  @impl true
  def process_event({:value_changed, {{label, value}, key}}, _, scene) do
    {:cont, {:value_changed, scene.assigns.opts[:id], value}, assign(scene, selected_label: label, selected_key: key, open?: false)}
  end

  def process_event(_, _, scene) do
    {:noreply, scene}
  end

  @impl true
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
    frame_height = opts[:frame_height] || @default_frame_height
    if(h > frame_height, do: frame_height, else: h)
  end

  defp get_content_height(items) do
    Items.get_height(items)
  end

  def get_theme(%{assigns: %{opts: opts}} = scene) do
    schema = FloUI.Themes.get_schema()
    theme = Scenic.Themes.normalize(opts[:theme]) || Scenic.Themes.normalize({:flo_ui, :dark})
    Scenic.Themes.validate(theme, schema)
    assign(scene, theme: theme)
  end
end
