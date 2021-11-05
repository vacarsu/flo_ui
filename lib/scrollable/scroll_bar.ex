defmodule FloUI.Scrollable.ContainerScrollBar do
  @moduledoc false

  import Scenic.Primitives, only: [rect: 3]
  alias Scenic.Graph
  alias Scenic.Primitive
  alias FloUI.Scrollable.Direction
  alias FloUI.Scrollable.Drag
  alias FloUI.Scrollable.Wheel
  alias FloUI.Scrollable.PositionCap
  alias Scenic.Primitive.Style.Theme
  alias Scenic.Math.Vector2

  use SnapFramework.Component,
    name: :scroll_bar,
    template: "lib/scrollable/scroll_bar.eex",
    controller: :none,
    assigns: [],
    opts: []

  defcomponent :scroll_bar, :map

  @default_drag_settings %{mouse_buttons: [:left, :right, :middle]}
  @default_button_radius 3
  @default_stroke_size 1
  @default_id :scroll_bar

  def setup(%{assigns: %{data: data, opts: opts}} = scene) do
    request_input(scene, [:cursor_pos])
    scene =
      assign(scene,
        id: opts[:id] || @default_id,
        width: data.width,
        height: data.height,
        direction: data.direction,
        content_size: Direction.from_vector_2(data.content_size, data.direction),
        frame_size: Direction.from_vector_2({data.width, data.height}, data.direction),
        scroll_position: Direction.return(data.scroll_position, data.direction),
        scroll_bar_slider_background: :released,
        last_scroll_position: Direction.return(data.scroll_position, data.direction),
        drag_state: Drag.init(opts[:scroll_drag] || @default_drag_settings),
        scroll_buttons:
          OptionEx.from_bool(opts[:scroll_buttons], %{
            scroll_button_1: :released,
            scroll_button_2: :released
          }),
        pid: self()
      )
      |> init_position_cap
      |> init_size
      |> init_scroll_bar_background
      |> init_scroll_bar_drag_control
      |> init_scroll_bar_buttons

    send_parent_event(scene, {:scroll_bar_initialized, scene.assigns})
    scene
  end

  def process_input(
    {:cursor_button, {button, :press, _, position}},
    :scroll_bar_slider_drag_control,
    %{assigns: %{
      drag_state: drag_state
    }} = scene
  ) do
    Logger.debug("drag control clicked")
    drag_state = Drag.handle_mouse_click(drag_state, button, position, local_scroll_position_vector2(scene))

    {:noreply, assign(scene, drag_state: drag_state)}
  end

  def process_input(
      {:cursor_button, {button, :release, _, position}},
      :scroll_bar_slider_drag_control,
      %{assigns: %{drag_state: drag_state}} = scene
    ) do
    drag_state = Drag.handle_mouse_release(drag_state, button, position)

    {:noreply, assign(scene, drag_state: drag_state)}
  end

  def process_input(
    {:cursor_pos, position},
    _,
    %{assigns: %{graph: graph, direction: direction, drag_state: drag_state}} = scene
  ) do
    # Logger.debug(inspect position)
    scroll_position =
      Direction.from_vector_2(position, direction)
      |> Direction.map_horizontal(fn pos -> pos - button_width(scene) / 2 end)
      |> Direction.map_vertical(fn pos -> pos - button_height(scene) / 2 end)

    scroll_position = local_to_world(scene, scroll_position)

    scene =
      assign(scene,
        drag_state: Drag.handle_mouse_move(drag_state, position),
        scroll_bar_slider_background: :released,
        last_scroll_position: scroll_position
      )

    drag_control_position = local_scroll_position_vector2(scene)
    graph = Graph.modify(graph, :scroll_bar_slider_drag_control, &Primitive.put_transform(&1, :translate, drag_control_position))

    scene =
      assign(scene, graph: graph)
      |> push_graph(graph)

    {:noreply, scene}
  end

  def process_input(
    {:cursor_pos, _},
    _,
    scene
  ) do
    {:noreply, scene}
  end

  def process_input(
    {:cursor_button, {_button, :press, _, _}},
    :scroll_button_1,
    %{assigns: %{direction: direction, scroll_buttons: {:some, scroll_buttons}}} = scene
  ) do
    scroll_buttons = %{scroll_buttons | scroll_button_1: :pressed}
    send_parent_event(scene, {:scroll_bar_button_pressed, direction, scroll_buttons})
    scene =
      scene
      |> assign(scroll_buttons: {:some, scroll_buttons})

    {:noreply, scene}
  end

  def process_input(
    {:cursor_button, {_button, :release, _, _}},
    :scroll_button_1,
    %{assigns: %{direction: direction, scroll_buttons: {:some, scroll_buttons}}} = scene
  ) do
    scroll_buttons = %{scroll_buttons | scroll_button_1: :released}
    send_parent_event(scene, {:scroll_bar_button_released, direction, scroll_buttons})
    scene =
      scene
      |> assign(scroll_buttons: {:some, scroll_buttons})

    {:noreply, scene}
  end

  def process_input(
    {:cursor_button, {_button, :press, _, _}},
    :scroll_button_2,
    %{assigns: %{direction: direction, scroll_buttons: {:some, scroll_buttons}}} = scene
  ) do
    scroll_buttons = %{scroll_buttons | scroll_button_2: :pressed}
    send_parent_event(scene, {:scroll_bar_button_pressed, direction, scroll_buttons})
    scene =
      scene
      |> assign(scroll_buttons: {:some, scroll_buttons})

    {:noreply, scene}
  end

  def process_input(
    {:cursor_button, {_button, :release, _, _}},
    :scroll_button_2,
    %{assigns: %{direction: direction, scroll_buttons: {:some, scroll_buttons}}} = scene
  ) do
    scroll_buttons = %{scroll_buttons | scroll_button_2: :released}
    send_parent_event(scene, {:scroll_bar_button_released, direction, scroll_buttons})
    scene =
      scene
      |> assign(scroll_buttons: {:some, scroll_buttons})

    {:noreply, scene}
  end

  defp init_scroll_bar_background(%{assigns: %{direction: :vertical, opts: opts, frame_size: frame_size}} = scene) do
    scroll_bar_background_width = opts[:scroll_bar_thickness]
    scroll_bar_background_height = Direction.unwrap(frame_size)
    scroll_bar_background_pos = {0, opts[:scroll_bar_thickness]}

    assign(
      scene,
      scroll_bar_background_width: scroll_bar_background_width,
      scroll_bar_background_height: scroll_bar_background_height,
      scroll_bar_background_pos: scroll_bar_background_pos
    )
  end

  defp init_scroll_bar_background(%{assigns: %{direction: :horizontal, opts: opts, frame_size: frame_size}} = scene) do
    scroll_bar_background_width = Direction.unwrap(frame_size)
    scroll_bar_background_height = opts[:scroll_bar_thickness]
    scroll_bar_background_pos = {opts[:scroll_bar_thickness], 0}

    assign(
      scene,
      scroll_bar_background_width: scroll_bar_background_width,
      scroll_bar_background_height: scroll_bar_background_height,
      scroll_bar_background_pos: scroll_bar_background_pos
    )
  end

  defp init_scroll_bar_drag_control(scene) do
    scroll_bar_drag_control_width = button_width(scene)
    scroll_bar_drag_control_height = button_height(scene)
    scroll_bar_drag_control_pos = local_scroll_position_vector2(scene)
    Logger.debug(inspect scroll_bar_drag_control_pos)
    assign(
      scene,
      scroll_bar_drag_control_width: scroll_bar_drag_control_width,
      scroll_bar_drag_control_height: scroll_bar_drag_control_height,
      scroll_bar_drag_control_pos: scroll_bar_drag_control_pos
    )
  end

  defp init_scroll_bar_buttons(%{assigns: %{direction: direction}} = scene) do
    size = scroll_button_size(scene)
    {button_2_x, button_2_y} =
      Direction.return(size, direction)
      |> Direction.add(scene.assigns.width)
      |> Direction.add(scene.assigns.height)
      |> Direction.to_vector_2()
    scroll_button_1_width = size
    scroll_button_1_height = size
    scroll_button_1_pos = {0, -2}
    scroll_button_2_width = size
    scroll_button_2_height = size
    scroll_button_2_pos = {button_2_x, button_2_y + 2}

    assign(scene,
      scroll_button_1_width: scroll_button_1_width,
      scroll_button_1_height: scroll_button_1_height,
      scroll_button_1_pos: scroll_button_1_pos,
      scroll_button_2_width: scroll_button_2_width,
      scroll_button_2_height: scroll_button_2_height,
      scroll_button_2_pos: scroll_button_2_pos
    )
  end

  defp init_size(%{assigns: %{scroll_buttons: :none, width: width, height: height}} = scene) do
    assign(scene,
      width: Direction.as_horizontal(width),
      height: Direction.as_vertical(height)
    )
  end

  defp init_size(%{assigns: %{scroll_buttons: {:some, _}, width: width, height: height}} = scene) do
    width = Direction.as_horizontal(width)
    height = Direction.as_vertical(height)

    displacement =
      scroll_bar_displacement(
        assign(scene, width: width, height: height)
      )

    button_size_difference = Direction.map(displacement, &(&1 * 2))

    assign(scene,
      width: Direction.subtract(width, button_size_difference),
      height: Direction.subtract(height, button_size_difference),
      scroll_bar_displacement: Direction.to_vector_2(displacement)
    )
  end

  defp init_position_cap(%{assigns: %{direction: direction}} = scene) do
    max =
      Direction.return(0, direction)
      |> Direction.add(scene.assigns.width)
      |> Direction.add(scene.assigns.height)
      |> Direction.map_horizontal(fn width ->
        width - button_width(scene) + scroll_button_size(scene)
      end)
      |> Direction.map_vertical(fn height ->
        height - button_height(scene) + scroll_button_size(scene)
      end)
      |> Direction.to_vector_2()

    min =
      scroll_bar_displacement(scene)
      |> Direction.to_vector_2()

    assign(scene, position_cap: PositionCap.init(%{min: min, max: max}))
  end

  defp scroll_button_size(%{assigns: %{scroll_buttons: :none}}), do: 0

  defp scroll_button_size(%{assigns: %{width: width, height: height, direction: direction}}) do
    Direction.return(1, direction)
    |> Direction.invert()
    |> Direction.multiply(width)
    |> Direction.multiply(height)
    |> Direction.unwrap()
  end

  defp button_width(%{assigns: %{direction: :horizontal}} = scene) do
    Direction.divide(scene.assigns.frame_size, scene.assigns.content_size)
    |> Direction.multiply(scene.assigns.width)
    |> Direction.unwrap()
  end

  defp button_width(scene), do: scene.assigns.opts[:scroll_bar_thickness]

  defp button_height(%{assigns: %{direction: :vertical}} = scene) do
    Direction.divide(scene.assigns.frame_size, scene.assigns.content_size)
    |> Direction.multiply(scene.assigns.height)
    |> Direction.unwrap()
  end

  defp button_height(scene), do: scene.assigns.opts[:scroll_bar_thickness]

  defp width_factor(%{assigns: %{content_size: {:horizontal, size}, width: {_, width}}}) do
    width / size
  end

  defp width_factor(_), do: 1

  defp height_factor(%{assigns: %{content_size: {:vertical, size}, height: {_, height}}}) do
    height / size
  end

  defp height_factor(_), do: 1

  # POSITION CALCULATIONS

  defp scroll_bar_displacement(%{assigns: %{direction: direction}} = scene) do
    scroll_button_size(scene)
    |> Direction.return(direction)
  end

  defp scroll_position_vector2(scene) do
    Direction.to_vector_2(scene.assigns.scroll_position)
  end

  defp local_scroll_position_vector2(scene) do
    world_to_local(scene, scroll_position_vector2(scene))
  end

  defp local_to_world(%{assigns: %{direction: :horizontal}} = scene, {:horizontal, x}) do
    {:horizontal, local_to_world(scene, x)}
  end

  defp local_to_world(%{assigns: %{direction: :vertical}} = assigns, {:vertical, y}) do
    {:vertical, local_to_world(assigns, y)}
  end

  defp local_to_world(_, {:horizontal, _}), do: {:horizontal, 0}

  defp local_to_world(_, {:vertical, _}), do: {:vertical, 0}

  defp local_to_world(scene, {x, y}) do
    {local_to_world(scene, x), local_to_world(scene, y)}
  end

  defp local_to_world(_, 0), do: 0

  defp local_to_world(%{assigns: %{direction: :horizontal}} = scene, x) do
    {x, _} = PositionCap.cap(scene.assigns.position_cap, {x, 0})
    -(x - scroll_button_size(scene)) / width_factor(scene)
  end

  defp local_to_world(%{assigns: %{direction: :vertical}} = scene, y) do
    {_, y} = PositionCap.cap(scene.assigns.position_cap, {0, y})
    -(y - scroll_button_size(scene)) / height_factor(scene)
  end

  defp world_to_local(%{assigns: %{direction: direction}} = scene, {x, y}) do
    position =
      Direction.from_vector_2({x, y}, direction)
      |> Direction.map(&world_to_local(scene, &1))
      |> Direction.to_vector_2()

    PositionCap.cap(scene.assigns.position_cap, position)
  end

  defp world_to_local(%{assigns: %{direction: :horizontal}} = scene, x),
    do: -x * width_factor(scene) + scroll_button_size(scene)

  defp world_to_local(%{assigns: %{direction: :vertical}} = scene, y),
    do: -y * height_factor(scene) + scroll_button_size(scene)
end
