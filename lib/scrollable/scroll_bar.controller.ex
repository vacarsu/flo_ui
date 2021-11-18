defmodule FloUI.Scrollable.ScrollBarController do
  alias Scenic.Graph
  alias Scenic.Primitive
  alias FloUI.Scrollable.Direction

  # def on_scroll_position_change(%{assigns: %{scroll_bar_state: %{scrolling: :wheel}}} = scene) do
  #   drag_control_position = local_scroll_position_vector2(scene)

  #   graph =
  #     scene.assigns.graph
  #     |> Graph.modify(
  #       :scroll_bar_slider_drag_control,
  #       &Primitive.put_transform(&1, :translate, drag_control_position)
  #     )

  #   Scenic.Scene.assign(scene, graph: graph)
  # end

  # def on_scroll_position_change(
  #       %{assigns: %{direction: :vertical, scroll_bar_state: %{scrolling: :dragging}}} =
  #         scene
  #     ) do
  #   drag_control_position = local_scroll_position_vector2(scene)
  #   graph =
  #     scene.assigns.graph
  #     |> Graph.modify(
  #       :scroll_bar_slider_drag_control,
  #       &Primitive.put_transform(&1, :translate, drag_control_position)
  #     )

  #   Scenic.Scene.assign(scene, graph: graph)
  # end

  # def on_scroll_position_change(
  #       %{assigns: %{direction: :horizontal, scroll_bar_state: %{scrolling: :dragging}}} =
  #         scene
  #     ) do
  #   drag_control_position = local_scroll_position_vector2(scene)
  #   graph =
  #     scene.assigns.graph
  #     |> Graph.modify(
  #       :scroll_bar_slider_drag_control,
  #       &Primitive.put_transform(&1, :translate, drag_control_position)
  #     )

  #   Scenic.Scene.assign(scene, graph: graph)
  # end

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

  defp scroll_button_size(%{assigns: %{scroll_bar_state: %{scroll_buttons: nil}}}), do: 0

  defp scroll_button_size(%{assigns: %{width: width, height: height, direction: direction}}) do
    Direction.return(1, direction)
    |> Direction.invert()
    |> Direction.multiply(width)
    |> Direction.multiply(height)
    |> Direction.unwrap()
  end

  # defp button_width(%{assigns: %{direction: :horizontal}} = scene) do
  #   Direction.divide(scene.assigns.frame_size, scene.assigns.content_size)
  #   |> Direction.multiply(scene.assigns.width)
  #   |> Direction.unwrap()
  # end

  # defp button_width(scene), do: scene.assigns.opts[:scroll_bar_thickness]

  # defp button_height(%{assigns: %{direction: :vertical}} = scene) do
  #   Direction.divide(scene.assigns.frame_size, scene.assigns.content_size)
  #   |> Direction.multiply(scene.assigns.height)
  #   |> Direction.unwrap()
  # end

  # defp button_height(scene), do: scene.assigns.opts[:scroll_bar_thickness]

  defp width_factor(%{assigns: %{content_size: {:horizontal, size}, width: {_, width}}}) do
    width / size
  end

  defp width_factor(_), do: 1

  defp height_factor(%{assigns: %{content_size: {:vertical, size}, height: {_, height}}}) do
    height / size
  end

  defp height_factor(_), do: 1

  # POSITION CALCULATIONS

  # defp scroll_position_vector2(scene) do
  #   Direction.to_vector_2(scene.assigns.scroll_position)
  # end

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
