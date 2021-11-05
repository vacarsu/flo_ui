defmodule FloUI.Scrollable.ScrollableContainer do
  @moduledoc false

  alias Scenic.Graph
  import Scenic.Primitives, only: [group: 3]
  alias Scenic.Math.Vector2

  alias FloUI.Scrollable.Hotkeys
  alias FloUI.Scrollable.Drag
  alias FloUI.Scrollable.Wheel
  alias FloUI.Scrollable.ScrollBars
  alias FloUI.Scrollable.Acceleration
  alias FloUI.Scrollable.PositionCap

  use SnapFramework.Component,
    name: :scrollable_container,
    template: "lib/scrollable/container.eex",
    controller: :none,
    assigns: [],
    opts: []

  defcomponent :scrollable_container, :map

  @default_position {0, 0}
  @default_fps 30

  def setup(%{assigns: %{data: data, opts: opts}} = scene) do
    Logger.debug(inspect data)
    {content_width, content_height} = data.content
    {frame_width, frame_height} = data.frame
    {frame_x, frame_y} = opts[:translate] || @default_position
    scroll_position = opts[:scroll_position] || @default_position

    assign(scene,
      id: opts[:id] || :scrollable,
      content_builder: opts[:content_builder],
      frame: %{x: frame_x, y: frame_y, width: frame_width, height: frame_height},
      content: %{x: 0, y: 0, width: content_width, height: content_height},
      scroll_position: Vector2.add(scroll_position, {0, 0}),
      fps: opts[:scroll_fps] || @default_fps,
      acceleration: Acceleration.init(opts[:scroll_acceleration]),
      hotkeys: Hotkeys.init(opts[:scroll_hotkeys]),
      drag_state: Drag.init(opts[:scroll_drag]),
      wheel_state: %Wheel{},
      scroll_bars_state: nil,
      scroll_bars: opts[:scroll_bars]
    )
    |> init_position_caps
  end

  def process_event({:scroll_bar_initialized, _scroll_bar_state}, _, scene) do
    scene = init_content(scene)

    {:noreply, scene}
  end

  def process_event({:scroll_bar_button_pressed, direction, scroll_buttons}, _, scene) do
    scene = update(scene)

    {:noreply, scene}
  end

  defp init_position_caps(
    %{assigns:
      %{
        frame: %{width: frame_width, height: frame_height},
        content: %{x: x, y: y, width: content_width, height: content_height}
      }
    } = scene
  ) do
    min = {x + frame_width - content_width, y + frame_height - content_height}
    max = {x, y}

    position_cap = PositionCap.init(%{min: min, max: max})

    assign(scene,
      position_caps: position_cap,
      scroll_position: PositionCap.cap(position_cap, scene.assigns.scroll_position)
    )
  end

  defp init_content(%{assigns: %{graph: graph, content_builder: content_builder, scroll_position: scroll_position, frame: frame, content: content}} = scene) do
    graph =
      Scenic.Primitives.group(
        graph,
        &group(&1, content_builder, [id: :content, translate: Vector2.add(scroll_position, {content.x, content.y})]),
        id: :frame,
        scissor: {frame.width, frame.height},
        translate: {frame.x, frame.y}
      )
    assign(scene, graph: graph)
    |> push_graph(graph)
  end

  defp update(scene) do
    scene
    |> update_scroll_state
    |> apply_force
    |> translate
    # |> update_scroll_bars
    |> tick
    # push_graph(scene, state.graph)
    # state
  end

  defp update_scroll_state(scene) do
    scrolling =
      verify_idle_state(scene)
      |> OptionEx.or_try(fn -> verify_dragging_state(scene) end)
      |> OptionEx.or_try(fn -> verify_scrolling_state(scene) end)
      |> OptionEx.or_try(fn -> verify_wheel_state(scene) end)
      |> OptionEx.or_try(fn -> verify_cooling_down_state(scene) end)

    assign(scene, scrolling: scrolling)
      # |> OptionEx.map(&%{scene.assigns | scrolling: &1})
      # |> OptionEx.or_else(scene)
  end

  defp apply_force(%{assigns: %{scrolling: :idle}} = scene), do: scene

  defp apply_force(%{assigns: %{scrolling: :dragging}} = scene) do
    scroll_position =
      scene.assigns.scroll_bars
      |> OptionEx.bind(&OptionEx.from_bool(ScrollBars.dragging?(&1), &1))
      |> OptionEx.bind(&ScrollBars.new_position/1)
      |> OptionEx.map(fn new_position ->
        Vector2.add(new_position, {scene.assigns.content.x, scene.assigns.content.y})
      end)
      |> OptionEx.or_try(fn ->
        OptionEx.from_bool(Drag.dragging?(scene.assigns.drag_state), scene.assigns.drag_state)
        |> OptionEx.bind(&Drag.new_position/1)
      end)

    assign(scene, scroll_position: PositionCap.cap(scene.assigns.position_caps, scroll_position))

    # |> OptionEx.map(&%{state | scroll_position: PositionCap.cap(state.position_caps, &1)})
    # |> OptionEx.or_else(state)
  end

  defp apply_force(%{assigns: %{scrolling: :wheel, wheel_state: %{offset: {:vertical, offset_y}}}} = scene) do
    {x, y} = scene.assigns.scroll_position
    scroll_position = {x, y + offset_y * 10}

    assign(scene, scroll_position: PositionCap.cap(scene.assigns.position_caps, scroll_position))
    # %{state | scroll_position: PositionCap.cap(state.position_caps, scroll_position)}
  end

  defp apply_force(%{assigns: %{scrolling: :wheel, wheel_state: %{offset: {:horizontal, offset_x}}}} = scene) do
    {x, y} = scene.assigns.scroll_position
    scroll_position = {x + offset_x * 10, y}

    assign(scene, scroll_position: PositionCap.cap(scene.assigns.position_caps, scroll_position))
    # %{state | scroll_position: PositionCap.cap(state.position_caps, scroll_position)}
  end

  # defp apply_force(%{assigns: assigns} = scene) do
  #   force =
  #     Hotkeys.direction(assigns.hotkeys)
  #     |> Vector2.add(get_scroll_bars_direction(scene))

  #   Acceleration.apply_force(assigns.acceleration, force)
  #   |> Acceleration.apply_counter_pressure()
  #   |> (&%{assigns | acceleration: &1}).()
  #   |> (fn assigns ->
  #     scroll_pos = Acceleration.translate(assigns.acceleration, scene.assigns.scroll_position)
  #     assign(scene, scroll_position: PositionCap.cap(assigns.position_caps, scroll_pos))
  #   end).()
  # end

  defp translate(%{assigns: %{graph: graph, content: %{x: x, y: y}}} = scene) do
    graph =
      graph
      |> Graph.modify(:content, &Scenic.Primitive.put_transform(&1, :translate, Vector2.add(scene.assigns.scroll_position, {x, y})))

    assign(scene, graph: graph)
    |> push_graph(graph)
    # Map.update!(state, :graph, fn graph ->
    #   graph
    #   |> Graph.modify(:content, fn primitive ->
    #     Map.update(primitive, :transforms, %{}, fn styles ->
    #       Map.put(styles, :translate, Vector2.add(state.scroll_position, {x, y}))
    #     end)
    #   end)
    # end)
  end

  defp verify_idle_state(%{assigns: assigns} = scene) do
    result =
      Hotkeys.direction(assigns.hotkeys) == {0, 0} and not
        Drag.dragging?(assigns.drag_state) and
        assigns.wheel_state.wheel_state != :scrolling and
        # get_scroll_bars_direction(assigns) == {0, 0} and not
        # scroll_bars_dragging?(scene) and
        Acceleration.is_stationary?(assigns.acceleration)
    OptionEx.from_bool(result, :idle)
  end

  defp verify_dragging_state(%{assigns: assigns} = scene) do
    result = Drag.dragging?(scene.assigns.drag_state)
      # or scroll_bars_dragging?(state)

    OptionEx.from_bool(result, :dragging)
  end

  defp verify_scrolling_state(%{assigns: assigns} = scene) do
    result =
      Hotkeys.direction(assigns.hotkeys) != {0, 0}
      # or (get_scroll_bars_direction(scene) != {0, 0} and not (assigns.scrolling == :dragging))

    OptionEx.from_bool(result, :scrolling)
  end

  defp verify_wheel_state(%{assigns: assigns} = scene) do
    {_, offset} = assigns.wheel_state.offset
    result =
      not Hotkeys.is_any_key_pressed?(assigns.hotkeys) and
      not Drag.dragging?(assigns.drag_state) and
      offset > 0 or offset < 0
      # and get_scroll_bars_direction(scene) == {0, 0} and
      # not scroll_bars_dragging?(scene)
    OptionEx.from_bool(result, :wheel)
  end

  defp verify_cooling_down_state(%{assigns: assigns} = scene) do
    {_, offset} = scene.wheel_state.offset
    result =
      not Hotkeys.is_any_key_pressed?(assigns.hotkeys) and
        not Drag.dragging?(assigns.drag_state) and
        offset == 0
        # and get_scroll_bars_direction(scene) == {0, 0} and
        # not scroll_bars_dragging?(scene) and
        not Acceleration.is_stationary?(assigns.acceleration)

    OptionEx.from_bool(result, :cooling_down)
  end

  defp start_cooling_down(%{assigns: assigns} = scene, cursor_pos) do
    speed =
      Drag.last_position(assigns.drag_state)
      |> OptionEx.or_else(cursor_pos)
      |> (&Vector2.sub(cursor_pos, &1)).()
      |> (&Drag.amplify_speed(assigns.drag_state, &1)).()

    assign(scene, acceleration: Acceleration.set_speed(assigns.acceleration, speed))
    # Map.update!(state, :acceleration, &Acceleration.set_speed(&1, speed))
  end

  defp capture_focus(%{assigns: %{focused: false}} = scene) do
    capture_input(scene, :key)

    assign(scene, focused: true)
  end

  defp capture_focus(state, _), do: state

  defp release_focus(%{assigns: %{focused: true}} = scene) do
    release_input(scene)

    assign(scene, focused: false)
  end

  defp release_focus(scene), do: scene

  defp tick(%{assigns: %{scrolling: :idle}} = scene), do: assign(scene, animating: false)

  defp tick(%{assigns: %{scrolling: :dragging}} = scene), do: assign(scene, animating: false)

  defp tick(%{assigns: %{scrolling: :wheel}} = scene), do: assign(scene, animating: false)

  defp tick(%{assigns: %{animating: true}} = scene), do: scene

  defp tick(scene) do
    Process.send_after(self(), :tick, tick_time(scene))
    assign(scene, animating: true)
  end

  defp tick_time(%{fps: fps}) do
    trunc(1000 / fps)
  end
end
