defmodule FloUI.Grid do
  @moduledoc """
  ## Usage in SnapFramework

  Render this with children passed to it to automatically lay the children out in the grid.
  The children must be given width and height styles for it to work. Inspired by https://github.com/BWheatie/scenic_layout_o_matic

  data is a map in the form of ` elixir %{start_xy: {0, 0}, max_xy: {100, 100}}`

  ``` elixir
  <%= component FloUI.Grid, %{
          start_xy: {0, 0},
          max_xy: {48 * 3, 48}
      },
      translate: {20, 120}
  do %>
      <%= component FloUI.Icon.Button, "Close", id: :icon_button, width: 48, height: 48, translate: {20, 120} do %>
          <%= component FloUI.Icon, {:flo_ui, "icons/clear_white.png"} %>
      <% end %>

      <%= component FloUI.Icon.Button, "Close", id: :icon_button, width: 48, height: 48, translate: {20, 120} do %>
          <%= component FloUI.Icon, {:flo_ui, "icons/clear_white.png"} %>
      <% end %>

      <%= component FloUI.Icon.Button, "Close", id: :icon_button, width: 48, height: 48, translate: {20, 120} do %>
          <%= component FloUI.Icon, {:flo_ui, "icons/clear_white.png"} %>
      <% end %>
  <% end %>
  ```
  """

  use SnapFramework.Component,
    name: :grid,
    template: "lib/layout/grid.eex",
    controller: :none,
    assigns: [last_height: 0, component_xy: {0, 0}, start_xy: {0, 0}, grid_xy: {0, 0}, max_xy: {0, 0}],
    opts: []

  defcomponent :grid, :map

  def setup(%{assigns: %{data: %{start_xy: start_xy, max_xy: max_xy}} = assigns} = scene) do
    assigns = %{assigns | component_xy: start_xy, start_xy: start_xy, grid_xy: start_xy, max_xy: max_xy}
    {_layout, children} = Enum.reduce(Enum.with_index(assigns.children), {assigns, []}, fn child, acc ->
      do_layout(child, acc)
    end)

    assign(scene, children: children)
  end

  def process_info(info, scene) do
    send_parent(scene, info)
    {:noreply, scene}
  end

  def process_update(data, _opts, scene) do
    assigns = %{scene.assigns | component_xy: scene.assigns.start_xy, start_xy: scene.assigns.start_xy, grid_xy: scene.assigns.start_xy, max_xy: scene.assigns.max_xy}
    {_layout, children} = Enum.reduce(Enum.with_index(assigns.children), {assigns, []}, fn child, acc ->
      do_layout(child, acc)
    end)

    {:noreply, assign(scene, children: children)}
  end

  defp do_layout({[
    type: _,
    module: _,
    data: _,
    opts: _
  ] = child, i}, {layout, child_list}) when is_list(child) do
    case translate(child, layout) do
      {:error, error} ->
        {:error, error}
      new_layout ->
        translate = new_layout.component_xy
        updated_child = [
          type: child[:type],
          module: child[:module],
          data: child[:data],
          opts: Keyword.put(child[:opts], :translate, translate)
        ]
        {new_layout, List.insert_at(child_list, i, updated_child)}
        # Map.put(new_layout, :children, List.replace_at(new_layout.children, i, updated_child))
    end
  end

  defp do_layout({[
    type: _,
    module: _,
    data: _,
    opts: _,
    children: _,
  ] = child, i}, {layout, child_list}) when is_list(child) do
    case translate(child, layout) do
      {:error, error} ->
        {:error, error}
      new_layout ->
        translate = new_layout.component_xy
        updated_child = [
          type: child[:type],
          module: child[:module],
          data: child[:data],
          opts: Keyword.put(child[:opts], :translate, translate),
          children: child[:children]
        ]
        {new_layout, List.insert_at(child_list, i, updated_child)}
        # Map.put(new_layout, :children, List.replace_at(new_layout.children, i, updated_child))
    end
  end

  defp do_layout({[
    type: _,
    module: _,
    data: _,
    children: _,
    opts: _,
  ] = child, i}, {layout, child_list}) when is_list(child) do
    case translate(child, layout) do
      {:error, error} ->
        {:error, error}
      new_layout ->
        translate = new_layout.component_xy
        updated_child = [
          type: child[:type],
          module: child[:module],
          data: child[:data],
          children: child[:children],
          opts: Keyword.put(child[:opts], :translate, translate)
        ]
        {new_layout, List.insert_at(child_list, i, updated_child)}
        # Map.put(new_layout, :children, List.replace_at(new_layout.children, i, updated_child))
    end
  end

  defp do_layout({child, _i}, {layout, child_list}) when is_list(child) do
    Enum.reduce(Enum.with_index(child), {layout, child_list}, fn nchild, acc ->
      do_layout(nchild, acc)
    end)
  end

  defp do_layout(_, layout) do
    layout
  end

  defp translate(
    child,
    %{
      last_height: last_height,
      start_xy: start_xy,
      grid_xy: grid_xy,
      max_xy: max_xy
    } = layout
  ) do
    width = child[:opts][:width]
    height = child[:opts][:height]
    {grid_x, _grid_y} = grid_xy
    {start_x, start_y} = start_xy
    new_x = start_x + width
    case start_xy == max_xy do
      true ->
        layout
        |> Map.put(:start_xy, {start_x, start_y})
        |> Map.put(:last_height, height)
      false ->
        # already in a new group, use start_xy
        case fits_in_x?(new_x, max_xy) do
          # fits in x
          true ->
            # fit in y?
            case fits_in_y?(start_y, max_xy) do
              true ->
                # fits
                layout
                |> Map.put(:start_xy, {new_x, start_y})
                |> Map.put(:component_xy, {start_x, start_y})
                |> Map.put(:last_height, height)

              # Does not fit
              false ->
                {:error, "Does not fit in grid"}
            end

          # doesnt fit in x
          false ->
            # fit in new y?
            new_y = start_y + last_height

            case fits_in_y?(new_y, max_xy) do
              true ->
                layout
                |> Map.put(:start_xy, {grid_x + width, new_y})
                |> Map.put(:component_xy, {grid_x, new_y})
                |> Map.put(:last_height, height)

              false ->
                {:error, "Does not fit in the grid"}
            end
        end
    end
  end

  defp fits_in_x?(potential_x, {max_x, _}), do: potential_x <= max_x

  defp fits_in_y?(potential_y, {_, max_y}), do: potential_y <= max_y
end
