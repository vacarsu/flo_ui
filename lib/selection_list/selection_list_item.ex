defmodule FloUI.SelectionListItem do
  @moduledoc """
  ## Usage in SnapFramework

  A selection list item used by SelectionList.

  data is a tuple in the form of
  ``` elixir
  {label, value, id}
  ```

  ``` elixir
  <%= graph font_size: 20 %>

  <%= component FloUI.SelectionListItem,
      {@label, @value, @key}
  %>
  ```
  """

  @default_theme FloUI.Theme.preset(:primary)

  use SnapFramework.Component,
    name: :selection_list_item,
    template: "lib/selection_list/selection_list_item.eex",
    controller: FloUI.SelectionListItemController,
    assigns: [
      hovered: false,
      width: 500,
      height: 50
    ],
    opts: []

  defcomponent(:selection_list_item, :tuple)

  watch([:hovered])

  use_effect([assigns: [selected: :any]],
    run: [:on_selected_change]
  )

  @impl true
  def setup(%{assigns: %{data: {label, value, key}, hovered: hovered, opts: opts}} = scene) do
    request_input(scene, [:cursor_pos])

    assign(scene,
      label: label,
      value: value,
      key: key,
      width: opts[:width] || 500,
      selected: opts[:selected] || false,
      hovered: hovered,
      theme: get_theme(opts)
    )
  end

  @impl true
  def bounds(_data, opts) do
    {0.0, 0.0, opts[:width] || 500, 50}
  end

  @impl true
  def process_input({:cursor_pos, _}, :box, scene) do
    {:noreply, assign(scene, hovered: true)}
  end

  def process_input({:cursor_pos, _}, _, scene) do
    {:noreply, assign(scene, hovered: false)}
  end

  def process_input(
        {:cursor_button, {:btn_left, 1, _, _}},
        :box,
        %{assigns: %{key: key, label: label, value: value, selected: false}} = scene
      ) do
    send_parent_event(scene, {:select, {label, value, key}})
    {:noreply, assign(scene, selected: true)}
  end

  def process_input(
        {:cursor_button, {:btn_left, 1, _, _}},
        :box,
        %{assigns: %{selected: true}} = scene
      ) do
    send_parent_event(scene, :deselect)
    {:noreply, assign(scene, selected: false)}
  end

  def process_input(_, _, scene) do
    {:noreply, scene}
  end

  @impl true
  def process_call(:deselect, _, scene) do
    {:reply, :ok, assign(scene, selected: false)}
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
