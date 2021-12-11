defmodule FloUI.Dropdown.Item do
  @moduledoc """
  ## Usage in SnapFramework

  An Item component used in `Dropdown.Items`.

  data is a tuple in the form of `{{label, value}, key}`
  """

  use SnapFramework.Component,
    name: :dropdown_item,
    template: "lib/dropdown/dropdown_item/dropdown_item.eex",
    controller: FloUI.Dropdown.ItemController,
    assigns: [],
    opts: []

  defcomponent(:dropdown_item, :tuple)

  watch([:hovered])

  # use_effect [assigns: [hovered: :any]], [
  #   run: [:on_hovered_change]
  # ]

  use_effect [assigns: [selected: :any]], [
    run: [:on_selected_change]
  ]

  @impl true
  def setup(%{assigns: %{data: {{label, value}, key}, opts: opts}} = scene) do
    selected = opts[:selected] || false
    if(selected, do: send_parent_event(scene, {:click, opts[:id], scene.assigns.data}))
    assign(scene,
      label: label,
      value: value,
      key: key,
      selected: selected,
      hovered: false,
      width: opts[:width],
      height: get_height()
    )
    |> get_theme
  end

  @impl true
  def bounds({_, _}, opts) do
    {0.0, 0.0, opts[:width], get_height()}
  end

  @impl true
  def process_input({:cursor_button, {:btn_left, 0, _, _}}, :bg, scene) do
    send_parent_event(scene, {:click, scene.assigns.opts[:id], scene.assigns.data})
    {:noreply, assign(scene, selected: true)}
  end

  def process_input({:cursor_pos, _}, :bg, scene) do
    request_input(scene, :cursor_pos)
    {:noreply, assign(scene, hovered: true)}
  end

  def process_input({:cursor_pos, _}, nil, scene) do
    unrequest_input(scene, :cursor_pos)
    {:noreply, assign(scene, hovered: false)}
  end

  def process_input(_, _, scene) do
    {:noreply, scene}
  end

  @impl true
  def process_cast(:deselect, scene) do
    {:noreply, assign(scene, selected: false)}
  end

  @spec get_height :: number
  def get_height() do
    FloUI.Util.FontMetricsHelper.get_text_height(20)
  end

  def get_theme(%{assigns: %{opts: opts}} = scene) do
    schema = FloUI.Themes.get_schema()
    theme = Scenic.Themes.normalize(opts[:theme]) || Scenic.Themes.normalize({:flo_ui, :dark})
    Scenic.Themes.validate(theme, schema)
    assign(scene, theme: theme)
  end
end
