defmodule FloUI.Scrollable.ScrollBarController do
  alias Scenic.Graph
  alias Scenic.Primitive
  alias FloUI.Scrollable.Direction

  def on_scrolling_change(scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(
        :scroll_bar_slider_background,
        &Primitive.put_style(&1, :stroke, {scene.assigns.opts[:border], {get_border_color(scene), 150}})
      )

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_scroll_position_change(scene) do
    drag_control_position = local_scroll_position_vector2(scene)

    graph =
      scene.assigns.graph
      |> Graph.modify(
        :scroll_bar_slider_drag_control,
        &Primitive.put_transform(&1, :translate, drag_control_position)
      )

    Scenic.Scene.assign(scene, graph: graph)
  end

  defp get_border_color(%{assigns: %{direction: :vertical, position_cap: position_cap}} = scene) do
    {_, y} = local_scroll_position_vector2(scene)
    {_, min} = position_cap.min
    {_, max} = position_cap.max
    if y <= min or y >= max do
      scene.assigns.theme.border
    else
      case scene.assigns.scroll_bar_state.scrolling do
        :dragging -> scene.assigns.theme.highlight
        :scrolling -> scene.assigns.theme.highlight
        :wheel -> scene.assigns.theme.highlight
        _ -> scene.assigns.theme.border
      end
    end
  end

  defp get_border_color(%{assigns: %{direction: :horizontal, position_cap: position_cap}} = scene) do
    {x, _} = local_scroll_position_vector2(scene)
    {min, _} = position_cap.min
    {max, _} = position_cap.max
    if x <= min or x >= max do
      scene.assigns.theme.border
    else
      case scene.assigns.scroll_bar_state.scrolling do
        :dragging -> scene.assigns.theme.highlight
        :scrolling -> scene.assigns.theme.highlight
        :wheel -> scene.assigns.theme.highlight
        _ -> scene.assigns.theme.border
      end
    end
  end

  defp scroll_button_size(%{assigns: %{scroll_bar_state: %{scroll_buttons: nil}}}), do: 0

  defp scroll_button_size(%{assigns: %{width: width, height: height, direction: direction}}) do
    Direction.return(1, direction)
    |> Direction.invert()
    |> Direction.multiply(width)
    |> Direction.multiply(height)
    |> Direction.unwrap()
  end

  defp width_factor(%{assigns: %{content_size: {:horizontal, size}, width: {_, width}}}) do
    width / size
  end

  defp width_factor(_), do: 1

  defp height_factor(%{assigns: %{content_size: {:vertical, size}, height: {_, height}}}) do
    height / size
  end

  defp height_factor(_), do: 1

  defp local_scroll_position_vector2(scene) do
    world_to_local(scene, scene.assigns.scroll_position)
  end

  defp world_to_local(scene, {:horizontal, x} = pos) do
    pos
    |> Direction.map(fn _ -> world_to_local(scene, x) end)
    |> Direction.to_vector_2()
  end

  defp world_to_local(scene, {:vertical, y} = pos) do
    pos
    |> Direction.map(fn _ -> world_to_local(scene, y) end)
    |> Direction.to_vector_2()
  end

  defp world_to_local(%{assigns: %{direction: direction}} = scene, {x, y}) do
    Direction.from_vector_2({x, y}, direction)
    |> Direction.map(&world_to_local(scene, &1))
    |> Direction.to_vector_2()
  end

  defp world_to_local(%{assigns: %{direction: :horizontal}} = scene, x),
    do: -x * width_factor(scene) + scroll_button_size(scene)

  defp world_to_local(%{assigns: %{direction: :vertical}} = scene, y),
    do: -y * height_factor(scene) + scroll_button_size(scene)
end
