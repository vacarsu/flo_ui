defmodule FloUI.Dropdown.Items do
  @moduledoc """
  ## Usage in SnapFramework

  A List of items for the dropdown component.

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
  """

  @default_max_height 300
  @default_theme FloUI.Theme.preset(:base)

  use SnapFramework.Component,
    name: :dropdown_items,
    template: "lib/dropdown/dropdown_items/dropdown_items.eex",
    controller: :none,
    assigns: [],
    opts: []

  defcomponent(:dropdown_items, :tuple)

  def setup(%{assigns: %{data: {items, selected}, opts: opts}} = scene) do
    assign(scene,
      items: items,
      selected: selected,
      width: get_width(items),
      content_height: get_content_height(items),
      max_height: opts[:max_height] || @default_max_height,
      theme: opts[:theme] || @default_theme
    )
  end

  def bounds({items, _}, opts) do
    {0.0, 0.0, get_width(items), get_height(items, opts[:max_height] || @default_max_height)}
  end

  def process_event({:click, id, {_, key} = data}, _, %{assigns: %{selected: selected}} = scene) do
    case child(scene, selected) do
      {:ok, [selected_pid]} ->
        GenServer.cast(selected_pid, :deselect)
      _ -> :ok
    end
    {:cont, {:value_changed, data}, assign(scene, selected: key)}
  end

  def get_width(items) do
    Enum.reduce(items, 0, fn {{label, _}, _}, l_width ->
      width = FloUI.Util.FontMetricsHelper.get_text_width(label, 20)

      if(width > l_width, do: width, else: l_width)
    end)
  end

  def get_height(items, max_height \\ @default_max_height) do
    height =
      Enum.reduce(items, 0, fn {{label, _}, _}, acc ->
        FloUI.Util.FontMetricsHelper.get_text_height(20) + acc
      end)

    if(height > max_height, do: max_height, else: height)
  end

  def get_content_height(items) do
    length(items) * 50
  end
end
