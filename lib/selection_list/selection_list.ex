defmodule FloUI.SelectionList do
  @moduledoc """
  ## Usage in SnapFramework

  Selection lists are a convenient way to have selectable options in list form.

  data is a tuple in the form of
  ``` elixir
  {[{label, value, key}], selected}
  ```

  ``` elixir
  <%= graph font_size: 20 %>

  <%= component FloUI.SelectionList,
      {@list, @selected},
      id: :selection_list
  %>
  ```
  """

  use SnapFramework.Component,
    name: :selection_list,
    template: "lib/selection_list/selection_list.eex",
    controller: :none,
    assigns: [
      width: 500
    ],
    opts: []

  defcomponent(:selection_list, :tuple)

  @impl true
  def setup(%{assigns: %{data: {list, selected}, opts: opts}} = scene) do
    assign(scene,
      items: list,
      selected: selected,
      id: opts[:id] || :selection_list,
      width: opts[:width] || 500,
      height: opts[:height] || 500
    )
  end

  @impl true
  def bounds({items, _selected}, opts) do
    {0.0, 0.0, opts[:width] || 500, length(items) * 50}
  end

  @impl true
  def process_event(
        {:select, {_label, _item_value, key} = item},
        _pid,
        %{assigns: %{id: id, selected: nil}} = scene
      ) do
    {:cont, {:value_changed, id, item}, assign(scene, selected: key)}
  end

  def process_event(
        {:select, {_label, _item_value, key} = item},
        _pid,
        %{assigns: %{id: id, selected: selected}} = scene
      ) do
    case child(scene, selected) do
      {:ok, [selected_pid]} -> GenServer.call(selected_pid, :deselect)
      _ -> selected
    end
    {:cont, {:value_changed, id, item}, assign(scene, selected: key)}
  end

  def process_event(:deselect, _, scene) do
    {:cont, {:value_changed, scene.assigns.id, nil}, assign(scene, selected: nil)}
  end
end
