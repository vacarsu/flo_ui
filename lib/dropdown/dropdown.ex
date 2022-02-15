defmodule FloUI.Dropdown do
  @moduledoc """
  ## Usage in SnapFramework

  Dropdown component that scrolls. You can pass two separate themes as options. One for the dropdown, and one for the scroll bar.

  Options
  ``` elixir
  disabled?: false,
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
    thickness: 15
  }

  alias FloUI.Dropdown.Items

  use SnapFramework.Component,
    name: :dropdown,
    type: :tuple,
    template: "lib/dropdown/dropdown.eex",
    controller: FloUI.DropdownController,
    assigns: [disabled?: false],
    opts: []

  use_effect([assigns: [disabled?: :any]],
    run: [:on_disabled_change]
  )

  use_effect([assigns: [open?: :any]],
    run: [:on_open_change]
  )

  use_effect([assigns: [selected_label: :any]],
    run: [:on_selected_change]
  )

  @impl true
  def setup(%{assigns: %{data: {items, selected} = data, opts: opts}} = scene) do
    frame_height = get_frame_height(data, opts)
    content_height = get_content_height(items)
    disabled? = opts[:disabled?] || scene.assigns.disabled?
    scroll_bar = opts[:scroll_bar] || @default_scroll_bar
    scroll_bar_thickness = scroll_bar[:thickness] || @default_scroll_bar[:thickness]
    show_vertical_scroll = scroll_bar[:show]
    width = get_width(data, Keyword.merge(opts, scroll_bar_thickness: scroll_bar_thickness))

    assign(scene,
      items: items,
      selected_label: "",
      selected_key: nil,
      selected: selected,
      disabled?: disabled?,
      open?: false,
      button_width: if(show_vertical_scroll, do: width + scroll_bar_thickness + 5, else: width),
      button_height: opts[:height] || @default_height,
      background_height: frame_height + 20,
      scroll_bar_thickness: scroll_bar_thickness,
      frame_width: width,
      frame_height: frame_height,
      content_width: width,
      content_height: content_height,
      scroll_bar: scroll_bar,
      show_vertical_scroll: show_vertical_scroll
    )
    |> get_selected
    |> get_theme
  end

  @impl true
  def bounds(data, opts) do
    {0.0, 0.0, get_width(data, opts), opts[:height] || @default_height}
  end

  @impl true
  def process_get(_from, scene) do
    {:reply, scene, scene}
  end

  @impl true
  def process_event({:value_changed, {{label, value}, key}}, _, scene) do
    {:cont, {:value_changed, scene.assigns.opts[:id], value},
     assign(scene, selected_label: label, selected_key: key, open?: false)}
  end

  def process_event(_, _, scene) do
    {:noreply, scene}
  end

  @impl true
  def process_input(
        {:cursor_button, {:btn_left, 0, _, _}},
        :bg,
        %{assigns: %{open?: open?}} = scene
      ) do
    {:noreply, assign(scene, open?: not open?)}
  end

  def process_input(
        {:cursor_button, {:btn_left, 1, _, _}},
        :clickout,
        %{assigns: %{open?: open?}} = scene
      ) do
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

  def get_selected(%{assigns: %{selected: selected, items: items}} = scene) do
    Enum.reduce(items, scene, fn {{label, value}, key}, acc ->
      if selected == value do
        assign(acc, selected_label: label, selected_key: key)
      else
        acc
      end
    end)
  end

  def get_theme(%{assigns: %{opts: opts}} = scene) do
    schema = FloUI.Themes.get_schema()

    case Scenic.Themes.validate(opts[:theme], schema) do
      {:ok, theme} -> assign(scene, theme: theme)
      {:error, _msg} -> assign(scene, theme: Scenic.Themes.normalize({:flo_ui, :dark}))
    end
  end
end
