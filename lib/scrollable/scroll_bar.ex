defmodule FloUI.Scrollable.ScrollBar do
  @moduledoc """
  Scroll bars are meant to be used within the Scrollable.Container component, but you can use them to build your own scrollable containers.

  The following events are sent.

  ``` elixir
  {:register_scroll_bar, direction, scroll_bar_state}
  {:drag_changed, direction, scroll_bar_state}
  {:scroll_bar_state_changed, direction, scroll_bar_state}
  ```

  additionally you can cast a vector2 offset to a scroll bar

  ``` elixir
  GenServer.cast(scroll_bar_pid, {:update_cursor_scroll, offset})
  ```

  data is an object in the form of

  ``` elixir
  %{
      direction: :vertical,
      content_size: {200, 200},
      width: 15,
      height: 500,
      scroll_position: {0, 0}
  }
  ```

  The following options are accepted

  ``` elixir
  [
    show_buttons: true,
    theme: Scenic.Primitive.Style.Theme.preset(:dark),
    border: 1,
    radius: 3,
    thickness: 15
  ]
  ```
  """

  alias Scenic.Graph
  alias FloUI.Scrollable.Direction
  alias FloUI.Scrollable.Drag
  alias FloUI.Scrollable.Wheel
  alias FloUI.Scrollable.PositionCap

  use SnapFramework.Component,
    name: :scroll_bar,
    template: "lib/scrollable/scroll_bar.eex",
    controller: FloUI.Scrollable.ScrollBarController,
    assigns: [],
    opts: []

  defcomponent(:scroll_bar, :map)

  @default_drag_settings %{mouse_buttons: [:btn_left, :btn_right, :btn_middle]}
  @default_id :scroll_bar

  use_effect([assigns: [scroll_position: :any]],
    run: [:on_scroll_position_change]
  )

  def setup(%{assigns: %{data: data, opts: opts}} = scene) do
    scene =
      assign(scene,
        id: opts[:id] || @default_id,
        width: data.width,
        height: data.height,
        direction: data.direction,
        content_size: Direction.from_vector_2(data.content_size, data.direction),
        frame_size: Direction.from_vector_2({data.width, data.height}, data.direction),
        scroll_position: Direction.from_vector_2(data.scroll_position, data.direction),
        scroll_bar_slider_background: :released,
        last_scroll_position: Direction.from_vector_2(data.scroll_position, data.direction),
        scroll_bar_state: %{
          scrolling: :idle,
          drag_state: Drag.init(opts[:scroll_drag] || @default_drag_settings),
          wheel_state: %Wheel{},
          scroll_buttons: nil,
          pid: self()
        }
      )
      |> init_scroll_buttons
      |> init_size
      |> init_position_cap
      |> init_scroll_bar_background
      |> init_scroll_bar_drag_control
      |> init_scroll_bar_buttons

    send_parent_event(
      scene,
      {:register_scroll_bar, scene.assigns.direction, scene.assigns.scroll_bar_state}
    )

    scene
  end

  def bounds(data, _opts) do
    {0.0, 0.0, data.width, data.height}
  end

  def process_update(data, _opts, scene) do
    {:noreply,
     assign(scene,
       last_scroll_position: scene.assigns.scroll_position,
       scroll_position: Direction.from_vector_2(data.scroll_position, scene.assigns.direction)
     )}
  end

  def process_input(
        {:cursor_button, {button, action, _, position}},
        :scroll_bar_slider_drag_control,
        %{assigns: %{direction: direction, scroll_bar_state: scroll_bar_state}} = scene
      ) do
    case action do
      0 ->
        unrequest_input(scene, [:cursor_pos, :cursor_button])
        scrolling = :idle

        scroll_position =
          Direction.from_vector_2(position, direction)
          |> Direction.map_horizontal(fn pos -> pos - button_width(scene) / 2 end)
          |> Direction.map_vertical(fn pos -> pos - button_height(scene) / 2 end)

        scroll_position = local_to_world(scene, scroll_position)

        drag_state =
          Drag.handle_mouse_release(
            scroll_bar_state.drag_state,
            button,
            position
          )

        scroll_bar_state = %{
          scroll_bar_state |
          scrolling: scrolling,
          drag_state: drag_state
        }

        scene = assign(scene,
          scroll_bar_state: scroll_bar_state,
          last_scroll_position: scene.assigns.scroll_position,
          scroll_position: scroll_position
        )

        send_parent_event(scene, {:drag_changed, direction, scroll_bar_state})

        {:noreply, scene}

      1 ->
        request_input(scene, [:cursor_pos, :cursor_button])
        scrolling = :dragging

        drag_state =
          Drag.handle_mouse_click(
            scroll_bar_state.drag_state,
            button,
            position,
            local_scroll_position_vector2(scene)
          )

        scroll_bar_state = %{
          scroll_bar_state |
          scrolling: scrolling,
          drag_state: drag_state
        }

        scene = assign(scene,
          scroll_bar_state: scroll_bar_state
        )

        send_parent_event(scene, {:drag_changed, direction, scroll_bar_state})

        {:noreply, scene}
    end
  end

  def process_input(
        {:cursor_pos, position},
        _,
        %{assigns: %{direction: direction, scroll_bar_state: scroll_bar_state}} =
          scene
      ) do
    scroll_position =
      Direction.from_vector_2(position, direction)
      |> Direction.map_horizontal(fn pos -> pos - button_width(scene) / 2 end)
      |> Direction.map_vertical(fn pos -> pos - button_height(scene) / 2 end)

    scroll_position = local_to_world(scene, scroll_position)

    drag_state = Drag.handle_mouse_move(scroll_bar_state.drag_state, position)

    scroll_bar_state = %{
      scroll_bar_state |
      drag_state: drag_state
    }

    scene =
      assign(scene,
        scroll_bar_state: scroll_bar_state,
        last_scroll_position: scene.assigns.scroll_position,
        scroll_position: scroll_position
      )

    send_parent_event(scene, {:scroll_bar_state_changed, direction, scroll_bar_state})

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
        {:cursor_button, {_button, 1, _, _}},
        :scroll_bar_slider_background,
        scene
      ) do
    {:noreply, scene}
  end

  def process_input(
        {:cursor_button, {_button, 0, _, position}},
        :scroll_bar_slider_background,
        %{assigns: %{direction: direction}} = scene
      ) do
    scene =
      scene
      |> assign(scroll_position: Direction.from_vector_2(position, direction))

    send_parent_event(scene, {:update_scroll_position, direction, local_to_world(scene, position)})

    {:noreply, scene}
  end

  def process_input(
        {:cursor_button, {button, 0, _, position}},
        nil,
        %{assigns: %{direction: direction, scroll_bar_state: scroll_bar_state}} = scene
      ) do
    unrequest_input(scene, [:cursor_pos, :cursor_button])
    scrolling = :idle

    drag_state =
      Drag.handle_mouse_release(
        scroll_bar_state.drag_state,
        button,
        position
      )

    scroll_bar_state = %{
      scroll_bar_state |
      scrolling: scrolling,
      drag_state: drag_state
    }

    scene = assign(scene, scroll_bar_state: scroll_bar_state)

    send_parent_event(scene, {:scroll_bar_state_changed, direction, scroll_bar_state})

    {:noreply, scene}
  end

  def process_input(
        {:cursor_button, {_button, 1, _, _}},
        button,
        %{assigns: %{direction: direction, scroll_bar_state: scroll_bar_state}} = scene
      ) do
    scroll_buttons = Map.update!(scroll_bar_state.scroll_buttons, button, fn _ -> :pressed end)
    scrolling = :scrolling
    scroll_bar_state = %{
      scroll_bar_state |
      scrolling: scrolling,
      scroll_buttons: scroll_buttons
    }

    scene =
      scene
      |> assign(scroll_bar_state: scroll_bar_state)

    send_parent_event(scene, {:scroll_bar_state_changed, direction, scroll_bar_state})

    {:noreply, scene}
  end

  def process_input(
        {:cursor_button, {_button, 0, _, _}},
        button,
        %{assigns: %{direction: direction, scroll_bar_state: scroll_bar_state}} = scene
      ) do
    scroll_buttons = Map.update!(scroll_bar_state.scroll_buttons, button, fn _ -> :released end)
    scrolling = :idle
    scroll_bar_state = %{
      scroll_bar_state |
      scrolling: scrolling,
      scroll_buttons: scroll_buttons
    }

    scene =
      scene
      |> assign(scroll_bar_state: scroll_bar_state)

    send_parent_event(scene, {:scroll_bar_state_changed, direction, scroll_bar_state})

    {:noreply, scene}
  end

  def process_cast(
        {:update_cursor_scroll, {{_, offset_y}, _}},
        %{assigns: %{direction: :vertical = direction, scroll_bar_state: scroll_bar_state}} = scene
      ) do
    scene =
      if offset_y == 0.0 do
        scroll_bar_state = %{
          scroll_bar_state |
          wheel_state: Wheel.stop_scrolling(scroll_bar_state.wheel_state, {direction, 0}),
          scrolling: :idle,
        }
        send_parent_event(scene, {:scroll_bar_state_changed, direction, scroll_bar_state})
        assign(scene, scroll_bar_state: scroll_bar_state)
      else
        scroll_bar_state = %{
          scroll_bar_state |
          wheel_state: Wheel.start_scrolling(scroll_bar_state.wheel_state, {direction, offset_y}),
          scrolling: :wheel,
        }
        send_parent_event(scene, {:scroll_bar_state_changed, direction, scroll_bar_state})
        assign(scene, scroll_bar_state: scroll_bar_state)
      end

    {:noreply, scene}
  end

  def process_cast(
        {:update_cursor_scroll, {{offset_x, _}, _}},
        %{assigns: %{direction: :horizontal = direction, scroll_bar_state: scroll_bar_state}} = scene
      ) do
    scene =
      if Float.floor(offset_x) == 0 or Float.ceil(offset_x) == 0 do
        scroll_bar_state = %{
          scroll_bar_state |
          wheel_state: Wheel.stop_scrolling(scroll_bar_state.wheel_state, {direction, offset_x}),
          scrolling: :idle,
        }
        send_parent_event(scene, {:scroll_bar_state_changed, direction, scroll_bar_state})
        assign(scene, scroll_bar_state: scroll_bar_state)
      else
        scroll_bar_state = %{
          scroll_bar_state |
          wheel_state: Wheel.start_scrolling(scroll_bar_state.wheel_state, {direction, offset_x}),
          scrolling: :wheel,
        }
        send_parent_event(scene, {:scroll_bar_state_changed, direction, scroll_bar_state})
        assign(scene, scroll_bar_state: scroll_bar_state)
      end

    {:noreply, scene}
  end

  defp init_scroll_bar_background(
         %{assigns: %{scroll_bar_state: %{scroll_buttons: nil}, direction: :vertical, opts: opts, height: height, frame_size: frame_size}} = scene
       ) do
    scroll_bar_background_width = opts[:thickness]
    scroll_bar_background_height = Direction.unwrap(height) + opts[:thickness]
    scroll_bar_background_pos = {0, 0}

    assign(
      scene,
      scroll_bar_background_width: scroll_bar_background_width,
      scroll_bar_background_height: scroll_bar_background_height,
      scroll_bar_background_pos: scroll_bar_background_pos
    )
  end

  defp init_scroll_bar_background(
         %{assigns: %{direction: :vertical, opts: opts, height: height, frame_size: frame_size}} = scene
       ) do
    scroll_bar_background_width = opts[:thickness]
    scroll_bar_background_height = Direction.unwrap(height)
    scroll_bar_background_pos = {0, opts[:thickness]}

    assign(
      scene,
      scroll_bar_background_width: scroll_bar_background_width,
      scroll_bar_background_height: scroll_bar_background_height,
      scroll_bar_background_pos: scroll_bar_background_pos
    )
  end

  defp init_scroll_bar_background(
         %{assigns: %{scroll_bar_state: %{scroll_buttons: nil}, direction: :horizontal, opts: opts, width: width, frame_size: frame_size}} = scene
       ) do
    scroll_bar_background_height = opts[:thickness]
    scroll_bar_background_width = Direction.unwrap(width) + opts[:thickness]
    scroll_bar_background_pos = {0, 0}

    assign(
      scene,
      scroll_bar_background_width: scroll_bar_background_width,
      scroll_bar_background_height: scroll_bar_background_height,
      scroll_bar_background_pos: scroll_bar_background_pos
    )
  end

  defp init_scroll_bar_background(
         %{assigns: %{direction: :horizontal, opts: opts, width: width, frame_size: frame_size}} = scene
       ) do
    scroll_bar_background_height = opts[:thickness]
    scroll_bar_background_width = Direction.unwrap(width)
    scroll_bar_background_pos = {opts[:thickness], 0}

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

  defp init_scroll_buttons(%{assigns: %{scroll_bar_state: scroll_bar_state, opts: opts}} = scene) do
    scroll_buttons =
      if opts[:show_buttons] do
        %{
          scroll_button_1: :released,
          scroll_button_2: :released
        }
      else
        nil
      end

    assign(scene, scroll_bar_state: %{scroll_bar_state | scroll_buttons: scroll_buttons})
  end

  # defp init_size(%{assigns: %{scroll_bar_state: %{scroll_buttons: nil}, width: width, height: height, opts: opts}} = scene) do
  #   scene =
  #     assign(scene,
  #       width: Direction.as_horizontal(height),
  #       height: Direction.as_vertical(width)
  #     )
  #   displacement = scroll_bar_displacement(scene)

  #   assign(scene, scroll_bar_displacement: Direction.to_vector_2(displacement))
  # end

  defp init_size(%{assigns: %{width: width, height: height}} = scene) do
    width = Direction.as_horizontal(width)
    height = Direction.as_vertical(height)

    displacement = scroll_bar_displacement(assign(scene, width: width, height: height))

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
      scene.assigns.scroll_bar_displacement
      |> Direction.to_vector_2()

    assign(scene, position_cap: PositionCap.init(%{min: min, max: max}))
  end

  defp scroll_button_size(%{assigns: %{scroll_bar_state: %{scroll_bars: nil}}}), do: 0

  defp scroll_button_size(%{assigns: %{width: width, height: height, direction: direction}}) do
    Direction.return(1, direction)
    |> Direction.invert()
    |> Direction.multiply(width)
    |> Direction.multiply(height)
    |> Direction.unwrap()
  end

  defp button_width(%{assigns: %{direction: :horizontal, scroll_bar_state: %{scroll_buttons: nil}, frame_size: frame_size}} = scene) do
    Direction.divide(scene.assigns.frame_size, scene.assigns.content_size)
    |> Direction.multiply(frame_size)
    |> Direction.unwrap()
  end

  defp button_width(%{assigns: %{direction: :horizontal}} = scene) do
    Direction.divide(scene.assigns.frame_size, scene.assigns.content_size)
    |> Direction.multiply(scene.assigns.width)
    |> Direction.unwrap()
  end

  defp button_width(scene), do: scene.assigns.opts[:thickness]

  defp button_height(%{assigns: %{direction: :vertical, scroll_bar_state: %{scroll_buttons: nil}, frame_size: frame_size}} = scene) do
    Direction.divide(scene.assigns.frame_size, scene.assigns.content_size)
    |> Direction.multiply(frame_size)
    |> Direction.unwrap()
  end

  defp button_height(%{assigns: %{direction: :vertical}} = scene) do
    Direction.divide(scene.assigns.frame_size, scene.assigns.content_size)
    |> Direction.multiply(scene.assigns.height)
    |> Direction.unwrap()
  end

  defp button_height(scene), do: scene.assigns.opts[:thickness]

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

  defp local_to_world(%{assigns: %{scroll_bar_state: %{scroll_buttons: nil}, direction: :horizontal}} = scene, x) do
    {x, _} = PositionCap.cap(scene.assigns.position_cap, {x, 0})
    -(x) / width_factor(scene)
  end

  defp local_to_world(%{assigns: %{direction: :horizontal}} = scene, x) do
    {x, _} = PositionCap.cap(scene.assigns.position_cap, {x, 0})
    -(x - scroll_button_size(scene)) / width_factor(scene)
  end

  defp local_to_world(%{assigns: %{scroll_bar_state: %{scroll_buttons: nil}, direction: :vertical}} = scene, y) do
    {_, y} = PositionCap.cap(scene.assigns.position_cap, {0, y})
    -(y) / height_factor(scene)
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

  defp world_to_local(%{assigns: %{scroll_bar_state: %{scroll_buttons: nil}, direction: :horizontal}} = scene, x),
    do: -x * width_factor(scene)

  defp world_to_local(%{assigns: %{direction: :horizontal}} = scene, x),
    do: -x * width_factor(scene) + scroll_button_size(scene)

  defp world_to_local(%{assigns: %{scroll_bar_state: %{scroll_buttons: nil}, direction: :vertical}} = scene, y),
    do: -y * height_factor(scene)

  defp world_to_local(%{assigns: %{direction: :vertical}} = scene, y),
    do: -y * height_factor(scene) + scroll_button_size(scene)
end
