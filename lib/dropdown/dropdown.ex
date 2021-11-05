defmodule FloUI.Dropdown do
  @moduledoc """
  ## Usage in SnapFramework

  Dropdown component which renders a scroll bar when when the list becomes greater then the height of the dropdown.

  data is a tuple in the form of ` elixir {items, selected}`

  item is a tuple in the form of
  ``` elixir
  {%{
    label: "label",
    value: value
  }, :id}
  ```

  style opts
    `width: :integer`
    `height: :integer`

  ``` elixir
  <%= component FloUI.Dropdown,
      {@dropdown_opts, @selected_opt},
      id: @opts[:id]
  %>
  ```
  """

  use Scenic.Component
  require Logger

  import Scenic.Primitives
  alias Scenic.Graph
  alias Scenic.Primitive
  alias Scenic.Math.Vector2

  alias FloUI.Icon
  alias FloUI.Scrollable.Acceleration
  alias FloUI.Scrollable.Hotkeys
  alias FloUI.Scrollable.Drag
  alias FloUI.Scrollable.Wheel
  alias FloUI.Scrollable.Direction
  alias FloUI.Scrollable.PositionCap
  alias FloUI.Scrollable.ScrollBar
  alias FloUI.Util.FontMetricsHelper

  @max_frame_height 300
  @button_id :btn_dropdown
  @selected_label_id :txt_selected
  @dropbox_id :dropbox
  @font_size 24
  @graph Graph.build(font_size: @font_size)

  def validate(nil), do: :invalid_data
  def validate(data), do: {:ok, data}

  def init(scene, {items, selected}, opts) do
    id = opts[:id]
    width = get_dropdown_width(items)
    height = opts[:styles][:height] || 50
    state =
      %{
        graph: @graph,
        id: id,
        items: items,
        selected: selected,
        width: width,
        height: height,
        dropdown_hidden: true,
        fps: 30,
        scrolling: :idle,
        animating: false,
        scroll_bar_pid: nil,
        scroll_bar: :none,
        scroll_state: :idle,
        position_cap: %PositionCap{},
        hotkeys: %Hotkeys{},
        drag_state: %Drag{},
        wheel_state: %Wheel{},
        acceleration: %Acceleration{},
        focused: false,
        scroll_position: {0, 0},
        content: %{x: 0, y: 0, width: width, height: get_dropdown_scroll_height(items)}
      }
      |> init_position_cap
      |> render_button
      |> render_clickout_bg
      |> render_dropdown
      |> update_highlighting(selected)

    scene =
      scene
      |> assign(state: state)
      |> push_graph(state.graph)

    {:ok, scene}
  end

  # ---------------------------------------------------------------------------
  # handle scroll bar events
  def handle_event({:scroll_bar_initialized, _id, scroll_bar_state}, from, scene) do
    state = %{scene.assigns.state | scroll_bar_pid: from, scroll_bar: OptionEx.return(scroll_bar_state)}
    {:noreply, assign(scene, state: state)}
  end

  def handle_event(
        {:scroll_bar_position_change, _, _scroll_bar_state},
        _from,
        %{assigns: %{scroll_state: :scrolling}} = scene
      ) do
    {:noreply, scene}
  end

  def handle_event({:scroll_bar_position_change, _id, scroll_bar_state}, _from, scene) do
    {x, y} = scene.assigns.state.scroll_position

    state =
      ScrollBar.new_position(scroll_bar_state)
      |> Direction.from_vector_2(scroll_bar_state.direction)
      |> Direction.map_horizontal(&{&1, y})
      |> Direction.map_vertical(&{x, &1})
      |> Direction.unwrap()
      |> (&Map.put(scene.assigns.state, :scroll_position, &1)).()
      |> update

    scene =
      scene
      |> assign(state: state)
      |> push_graph(state.graph)

    {:noreply, scene}
  end

  def handle_event({:scroll_bar_scroll_end, _id, scroll_bar_state}, _from, scene) do
    state =
      %{scene.assigns.state | scroll_bar: OptionEx.return(scroll_bar_state)}
      |> update

    scene =
      scene
      |> assign(state: state)
      |> push_graph(state.graph)

    {:noreply, scene}
  end

  def handle_event({:scroll_bar_button_pressed, _id, scroll_bar_state}, _from, scene) do
    state =
      %{scene.assigns.state | scroll_bar: OptionEx.return(scroll_bar_state)}
      |> update

    scene =
      scene
      |> assign(state: state)
      |> push_graph(state.graph)

    {:noreply, scene}
  end

  def handle_event({:scroll_bar_button_released, _id, scroll_bar_state}, _from, scene) do
    state =
      %{scene.assigns.state | scroll_bar: OptionEx.return(scroll_bar_state)}
      |> update

    scene =
      scene
      |> assign(state: state)
      |> push_graph(state.graph)

    {:noreply, scene}
  end

  def handle_event({:cursor_scroll_started, _id, scroll_bar_state}, _from, %{assigns: %{state: state}} = scene) do
    state =
      %{state | scroll_bar: OptionEx.return(scroll_bar_state), wheel_state: scroll_bar_state.wheel_state}
      |> update()

    scene =
      scene
      |> assign(state: state)
      |> push_graph(state.graph)

    {:noreply, scene}
  end

  def handle_event({:cursor_scroll_stopped, _id, scroll_bar_state}, _from, %{assigns: %{state: state}} = scene) do
    state =
      %{state | scroll_bar: OptionEx.return(scroll_bar_state), wheel_state: scroll_bar_state.wheel_state}
      |> update()

    scene =
      scene
      |> assign(state: state)
      |> push_graph(state.graph)

    {:noreply, scene}
  end

  def handle_event(event, _, scene) do
    {:cont, event, scene}
  end

  # ---------------------------------------------------------------------------
  # handle button clicks

  def handle_input(
    {:cursor_button, {:btn_left, 0, _, _}},
    @button_id,
    %{assigns: %{state: %{selected: selected, dropdown_hidden: true}}} = scene
  ) do
    state =
      scene.assigns.state
      |> toggle_dropdown()
      |> update_highlighting(selected)
    scene =
      scene
      |> assign(state: state)
      |> push_graph(state.graph)
    {:noreply, scene}
  end

  def handle_input(
    {:cursor_button, {:btn_left, 0, _, _}},
    @button_id,
    %{assigns: %{state: %{selected: selected, dropdown_hidden: false}}} = scene
  ) do
    state =
      scene.assigns.state
      |> toggle_dropdown()
      |> update_highlighting(selected)
    scene =
      scene
      |> assign(state: state)
      |> push_graph(state.graph)
    {:noreply, scene}
  end

  def handle_input(
        {:cursor_button, {:btn_left, 0, _, _}},
        :scroll_bar,
        scene
      ) do
    {:noreply, scene}
  end

  # ---------------------------------------------------------------------------
  # handle click outside
  # close dropdown and release input
  def handle_input(
        {:cursor_button, {:btn_left, 0, _, _}},
        :clickout,
        %{assigns: %{state: %{scroll_bar_pid: scroll_pid, selected: selected, dropdown_hidden: false}}} = scene
      ) do
    GenServer.cast(scroll_pid, :unrequest_cursor_scroll)
    state =
      scene.assigns.state
      |> toggle_dropdown()
      |> update_highlighting(selected)
    scene =
      scene
      |> assign(state: state)
      |> push_graph(state.graph)
    {:noreply, scene}
  end

  # def handle_input(
  #       {:cursor_button, {0, :release, _, _}},
  #       @dropbox_id,
  #       scene
  #     ) do
  #   {:noreply, scene}
  # end

  # ---------------------------------------------------------------------------
  # Handle item clicks
  def handle_input(
        {:cursor_button, {:btn_left, 0, _, _}},
        item_id,
        %{assigns: %{state: %{id: id, items: items}}} = scene
      ) do
    state =
      %{scene.assigns.state | selected: item_id}
      |> toggle_dropdown
      |> update_selected_label
      |> update_highlighting(item_id)

    send_parent_event(scene, {:value_changed, id, get_selected_value(items, item_id)})
    scene =
      scene
      |> assign(state: state)
      |> push_graph(state.graph)

    {:noreply, scene}
  end

  # ---------------------------------------------------------------------------
  # Ignore button mouse overs
  def handle_input({:cursor_pos, _}, @button_id, scene) do
    {:noreply, scene}
  end

  # def handle_input({:cursor_pos, _}, @button_id, scene) do
  #   {:noreply, scene}
  # end

  # ---------------------------------------------------------------------------
  # Handle item mouse over highlighting
  def handle_input({:cursor_pos, _}, item_id, scene) do
    state = update_highlighting(scene.assigns.state, item_id)
    scene =
      scene
      |> assign(state: state)
      |> push_graph(state.graph)
    {:noreply, scene}
  end

  # def handle_input({:cursor_pos, _}, item_id, scene) do
  #   state = update_highlighting(scene.assigns.state, item_id)
  #   scene =
  #     scene
  #     |> assign(state: state)
  #     |> push_graph(state.graph)
  #   {:noreply, scene}
  # end

  def handle_input({:cursor_scroll, scroll_pos}, :scroll_capture, %{assigns: %{state: state}} = scene) do
    GenServer.cast(state.scroll_bar_pid, {:update_cursor_scroll, scroll_pos})
    {:noreply, scene}
  end

  # ---------------------------------------------------------------------------
  # Catch unhandled events
  def handle_input(_event, _context, scene) do
    {:noreply, scene}
  end

  def handle_info(:tick, scene) do
    state =
      %{scene.assigns.state | animating: false}
      |> update
    scene =
      scene
      |> assign(state: state)
      |> push_graph(state.graph)
    {:noreply, scene}
  end

  defp toggle_dropdown(%{graph: graph, dropdown_hidden: true, items: items, content: content} = state) do
    show_scroll_bar = if get_dropdown_frame_height(items) < content.height, do: false, else: true
    graph =
      graph
      |> Graph.modify(:content_container, &Primitive.put_style(&1, :hidden, false))
      |> Graph.modify(:dropdown_bg, &Primitive.put_style(&1, :hidden, false))
      |> Graph.modify(:clickout, &Primitive.put_style(&1, :hidden, false))
      |> Graph.modify(:icon, &Primitive.put_transform(&1, :rotate, :math.pi()))
      |> Graph.modify(:scroll_bar, &Primitive.put_style(&1, :hidden, show_scroll_bar))

    %{state | graph: graph, dropdown_hidden: false}
  end

  defp toggle_dropdown(%{graph: graph, dropdown_hidden: false} = state) do
    graph =
      graph
      |> Graph.modify(:content_container, &Primitive.put_style(&1, :hidden, true))
      |> Graph.modify(:dropdown_bg, &Primitive.put_style(&1, :hidden, true))
      |> Graph.modify(:clickout, &Primitive.put_style(&1, :hidden, true))
      |> Graph.modify(:icon, &Primitive.put_transform(&1, :rotate, 0))
      |> Graph.modify(:scroll_bar, &Primitive.put_style(&1, :hidden, true))

    %{state | graph: graph, dropdown_hidden: true}
  end

  defp render_button(
         %{graph: graph, width: width, height: height, items: items, selected: selected} = state
       ) do
    graph
    |> rect({width, height - 1},
      stroke: {1, :white},
      fill: :black
    )
    |> text(get_selected_label(items, selected),
      translate: {5, 30},
      id: @selected_label_id
    )
    |> Icon.add_to_graph({:flo_ui, "icons/arrow_drop_down_white.png"},
      id: :icon,
      translate: {width - 48, 0},
      pin: {48 / 2, 48 / 2}
    )
    |> rect({width, height - 1},
      id: @button_id,
      input: :cursor_button
    )
    |> (&%{state | graph: &1}).()
  end

  defp render_clickout_bg(%{graph: graph} = state) do
    graph
    |> rect({8000, 8000}, t: {-4000, -4000}, id: :clickout, input: :cursor_button, hidden: true)
    |> (&%{state | graph: &1}).()
  end

  defp render_dropdown(%{graph: graph, width: width, height: height, items: items, scroll_position: {_x, y}} = state) do
    graph
    |> rect({width, get_dropdown_frame_height(items)+5},
      id: :dropdown_bg,
      translate: {0, height},
      fill: :black,
      stroke: {1, :white},
      hidden: true
    )
    |> group(fn g ->
        g
        |> group(fn g ->
          g
          |> (&Enum.reduce(Enum.with_index(items), &1, fn {{item, id}, i}, g ->
            g
            |> group(
              fn g ->
                g
                |> rect(
                  {width, height},
                  translate: {0, 0},
                  id: id,
                  input: [:cursor_pos, :cursor_button]
                )
                |> text(
                  item.label,
                  translate: {5, 25},
                  text_align: :left
                )
                |> rect(
                  {width, get_dropdown_frame_height(items)+5},
                  translate: {0, 0},
                  id: :scroll_capture,
                  input: :cursor_scroll
                )
              end,
              translate: {0, height * i}
            )
          end)).()
        end,
        id: @dropbox_id,
        translate: {0, 0}
      ) end,
      scissor: {width, get_dropdown_frame_height(items)},
      id: :content_container,
      translate: {0, height},
      width: width,
      hidden: true,
      height: get_dropdown_frame_height(items)
    )
    |> ScrollBar.add_to_graph(
      %{
        width: 15,
        height: get_dropdown_frame_height(items),
        content_size: get_dropdown_scroll_height(items),
        scroll_position: y,
        direction: :vertical
      },
      id: :scroll_bar,
      translate: {width-16, height + 2},
      scroll_buttons: true,
      scroll_bar_theme: Scenic.Primitive.Style.Theme.preset(:dark),
      scroll_bar_thickness: 15,
      hidden: true
    )
    |> (&%{state | graph: &1}).()
  end

  defp update(state) do
    state
    |> update_scroll_state
    |> apply_force
    |> translate_content
    |> update_scroll_bars
    |> tick
  end

  defp update_scroll_bars(%{scroll_position: {_x, y}} = state) do
    GenServer.call(state.scroll_bar_pid, {:update_scroll_position, y})
    state
  end

  defp update_scroll_state(state) do
    verify_idle_state(state)
    |> OptionEx.or_try(fn -> verify_dragging_state(state) end)
    |> OptionEx.or_try(fn -> verify_scrolling_state(state) end)
    |> OptionEx.or_try(fn -> verify_wheel_state(state) end)
    |> OptionEx.or_try(fn -> verify_cooling_down_state(state) end)
    |> OptionEx.map(&%{state | scrolling: &1})
    |> OptionEx.or_else(state)
  end

  defp apply_force(%{scrolling: :idle} = state), do: state

  defp apply_force(%{scrolling: :dragging} = state) do
    state.scroll_bar
    |> OptionEx.bind(&OptionEx.from_bool(ScrollBar.dragging?(&1), &1))
    |> OptionEx.bind(&ScrollBar.new_position/1)
    |> OptionEx.map(fn new_position ->
      Vector2.add(new_position, {state.content.x, state.content.y})
    end)
    |> OptionEx.or_try(fn ->
      OptionEx.from_bool(Drag.dragging?(state.drag_state), state.drag_state)
      |> OptionEx.bind(&Drag.new_position/1)
    end)
    |> OptionEx.map(&%{state | scroll_position: PositionCap.cap(state.position_cap, &1)})
    |> OptionEx.or_else(state)
  end

  defp apply_force(%{scrolling: :wheel, wheel_state: %{offset: {_, offset_y}}} = state) do
    {_, y} = state.scroll_position
    scroll_position = {0, y + offset_y * 10}

    %{state | scroll_position: PositionCap.cap(state.position_cap, scroll_position)}
  end

  defp apply_force(state) do
    force =
      Hotkeys.direction(state.hotkeys)
      |> Vector2.add(get_scroll_bar_direction(state))

    Acceleration.apply_force(state.acceleration, force)
    |> Acceleration.apply_counter_pressure()
    |> (&%{state | acceleration: &1}).()
    |> (fn state ->
          Map.update(state, :scroll_position, {0, 0}, fn scroll_pos ->
            scroll_pos = Acceleration.translate(state.acceleration, scroll_pos)
            PositionCap.cap(state.position_cap, scroll_pos)
          end)
        end).()
  end

  defp verify_idle_state(state) do
    result =
      Hotkeys.direction(state.hotkeys) == {0, 0} and not Drag.dragging?(state.drag_state) and
        state.wheel_state.wheel_state != :scrolling and
        get_scroll_bar_direction(state) == {0, 0} and not scroll_bars_dragging?(state) and
        Acceleration.is_stationary?(state.acceleration)

    OptionEx.from_bool(result, :idle)
  end

  defp verify_dragging_state(state) do
    result = Drag.dragging?(state.drag_state) or scroll_bars_dragging?(state)

    OptionEx.from_bool(result, :dragging)
  end

  defp verify_scrolling_state(state) do
    result =
      Hotkeys.direction(state.hotkeys) != {0, 0} or
        (get_scroll_bar_direction(state) != {0, 0} and not (state.scrolling == :dragging))

    OptionEx.from_bool(result, :scrolling)
  end

  defp verify_wheel_state(state) do
    {_, offset} = state.wheel_state.offset
    result =
      not Hotkeys.is_any_key_pressed?(state.hotkeys) and
      not Drag.dragging?(state.drag_state) and
      offset > 0 or offset < 0 and
      get_scroll_bar_direction(state) == {0, 0} and
      not scroll_bars_dragging?(state)
    OptionEx.from_bool(result, :wheel)
  end

  defp verify_cooling_down_state(state) do
    result =
      not Hotkeys.is_any_key_pressed?(state.hotkeys) and not Drag.dragging?(state.drag_state) and
        get_scroll_bar_direction(state) == {0, 0} and not scroll_bars_dragging?(state) and
        not Acceleration.is_stationary?(state.acceleration)

    OptionEx.from_bool(result, :cooling_down)
  end

  defp update_selected_label(%{graph: graph, items: items, selected: selected} = state) do
    graph
    |> Graph.modify(@selected_label_id, &text(&1, get_selected_label(items, selected)))
    |> (&%{state | graph: &1}).()
  end

  defp update_highlighting(%{graph: graph, items: items, selected: selected} = state, hovered) do
    Enum.reduce(items, graph, fn
      # this is the item the user is hovering over
      {_, ^hovered}, g ->
        Graph.modify(g, hovered, &update_opts(&1, fill: :steel_blue))

      # this is the currently selected item
      {_, ^selected}, g ->
        Graph.modify(g, selected, &update_opts(&1, fill: :steel_blue))

      # not selected, not hovered over
      {_, regular_id}, g ->
        Graph.modify(g, regular_id, &update_opts(&1, fill: :black))
    end)
    |> (&%{state | graph: &1}).()
  end

  defp get_selected_label(items, selected) do
    Enum.find_value(items, "", fn
      {%{label: label}, ^selected} -> label
      _ -> false
    end)
  end

  defp get_selected_value(items, selected) do
    Enum.find_value(items, "", fn
      {%{value: value}, ^selected} -> value
      _ -> nil
    end)
  end

  def get_dropdown_width(items) do
    Enum.reduce(items, 0, fn {item, _id}, acc ->
      width = FontMetricsHelper.get_text_width(item.label, @font_size) + 48
      if width > acc, do: width, else: acc
    end)
  end

  defp translate_content(%{content: %{x: x, y: y}} = state) do
    Map.update!(state, :graph, fn graph ->
      graph
      |> Graph.modify(@dropbox_id, fn primitive ->
        Map.update(primitive, :transforms, %{}, fn styles ->
          Map.put(styles, :translate, Vector2.add(state.scroll_position, {x, y}))
        end)
      end)
    end)
  end

  defp init_position_cap(
         %{
           items: items,
           width: width,
           content: %{x: x, y: y}
         } = state
       ) do
    min = {x + width - width, y + get_dropdown_frame_height(items) - get_dropdown_scroll_height(items)}
    max = {x, y}

    position_cap = PositionCap.init(%{min: min, max: max})

    Map.put(state, :position_cap, position_cap)
    |> Map.update(:scroll_position, {0, 0}, &PositionCap.cap(position_cap, &1))
  end

  defp get_dropdown_scroll_height(items) do
    length(items) * 50
  end

  defp get_dropdown_frame_height(items) do
    frame_height = length(items) * 50
    if frame_height > @max_frame_height do
      @max_frame_height
    else
      frame_height
    end
  end

  defp tick(%{scrolling: :idle} = state), do: %{state | animating: false}

  defp tick(%{scrolling: :dragging} = state), do: %{state | animating: false}

  defp tick(%{scrolling: :wheel} = state), do: %{state | animating: false}

  defp tick(%{animating: true} = state), do: state

  defp tick(state) do
    Process.send_after(self(), :tick, tick_time(state))
    %{state | animating: true}
  end

  defp tick_time(%{fps: fps}) do
    trunc(1000 / fps)
  end

  defp get_scroll_bar_direction(%{scroll_bar: :none}), do: {0, 0}

  defp get_scroll_bar_direction(%{scroll_bar: {:some, scroll_bar}}),
    do: ScrollBar.direction(scroll_bar)

  defp scroll_bars_dragging?(%{scroll_bar: :none}), do: false

  defp scroll_bars_dragging?(%{scroll_bar: {:some, scroll_bar}}),
    do: ScrollBar.dragging?(scroll_bar)
end
