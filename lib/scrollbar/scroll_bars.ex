# defmodule FloUI.Scrollable.ScrollBars do
#   use Scenic.Component
#   # use FloUI.Scrollable.SceneInspector, env: [:test, :dev]

#   import FloUI.Scrollable.Components, only: [scroll_bar: 3]

#   alias Scenic.Graph

#   alias FloUI.Scrollable.ScrollBar
#   alias FloUI.Scrollable.Direction

#   @moduledoc """
#   The scroll bars component can be used to add a horizontal, and a vertical scroll bar pair to the graph. This component is used internally by the `Scenic.Scrollable` component, and for most cases it is recommended to use the `Scenic.Scrollable` component instead.

#   ## Data

#   `t:Scenic.Scrollable.ScrollBars.settings/0`

#   The scroll bars require the following data for initialization:

#   - width: number
#   - height: number
#   - content_size: `t:Scenic.Scrollable.ScrollBars.v2/0`
#   - scroll_position: number
#   - direction: :horizontal | :vertical

#   With and height define the size of the frame, and thus correspond to the width of the horizontal, and the height of the vertical scroll bars.

#   ## Styles

#   `t:Scenic.Scrollable.ScrollBars.styles/0`

#   The scroll bars can be customized by using the following styles:

#   ### scroll_bar

#   `t:Scenic.Scrollable.ScrollBar.styles/0`

#   The styles to customize both scrollbars as defined in the corresponding module `Scenic.Scrollable.Scrollbar`.
#   If different styles for the horizontal and vertical scroll bars are preffered, use the horizontal_scroll_bar and vertical_scroll_bar styles instead.

#   ### horizontal_scroll_bar

#   `t:Scenic.Scrollable.ScrollBar.styles/0`

#   The styles to customize the horizontal scroll bar.

#   ### vertical_scroll_bar

#   `t:Scenic.Scrollable.ScrollBar.styles/0`

#   The styles to customize the vertical scroll bar.

#   ### scroll_drag

#   `t:Scenic.Scrollable.Drag/0`

#   Settings to specify which mouse buttons can be used in order to drag the scroll bar sliders.

#   ### scroll_bar_thickness

#   number

#   Specify the height of the horizontal, and the width of the vertical scroll bars.

#   ## Examples

#       iex> graph = Scenic.Scrollable.Components.scroll_bars(
#       ...>   Scenic.Graph.build(),
#       ...>   %{
#       ...>     width: 200,
#       ...>     height: 200,
#       ...>     content_size: {1000, 1000},
#       ...>     scroll_position: {0, 0}
#       ...>   },
#       ...>   [
#       ...>     scroll_bar: [
#       ...>       scroll_buttons: true,
#       ...>       scroll_bar_theme: Scenic.Primitive.Style.Theme.preset(:light),
#       ...>       scroll_bar_radius: 2,
#       ...>       scroll_bar_border: 2,
#       ...>       scroll_drag: %{
#       ...>         mouse_buttons: [:left, :right, :middle]
#       ...>       }
#       ...>     ],
#       ...>     scroll_drag: %{
#       ...>       mouse_buttons: [:left, :right, :middle]
#       ...>     },
#       ...>     id: :scroll_bars_component_1
#       ...>   ]
#       ...> )
#       ...> graph.primitives[1].id
#       :scroll_bars_component_1
#   """

#   @typedoc """
#   Data structure representing a vector 2, in the form of an {x, y} tuple.
#   """
#   @type v2 :: Scenic.Scrollable.v2()

#   @type content_size :: {number, number}

#   @typedoc """
#   The required settings to initialize a scroll bars component.
#   For more information see the top of this module.
#   """
#   @type settings :: %{
#           width: number,
#           height: number,
#           content_size: v2,
#           scroll_position: v2
#         }

#   @typedoc """
#   The optional styles to customize the scroll bars.
#   For more information see the top of this module.
#   """
#   @type style ::
#           {:scroll_bar, Scenic.Scrollable.ScrollBar.styles()}
#           | {:horizontal_scroll_bar, Scenic.Scrollable.ScrollBar.styles()}
#           | {:vertical_scroll_bar, Scenic.Scrollable.ScrollBar.styles()}
#           | {:scroll_drag, Scenic.Scrollable.Drag.settings()}
#           | {:scroll_bar_thickness, number}

#   @typedoc """
#   A collection of optional styles to customize the scroll bars.
#   For more information see `t:Scenic.Scrollable.ScrollBars.style/0` and the top of this module.
#   """
#   @type styles :: [style]

#   @typedoc """
#   An atom describing the state the scroll bars are in.
#   - idle: none of the scroll bars are currently being clicked or dragged.
#   - dragging: one of the scroll bars is being dragged.
#   - scrolling: one of the scroll bars is being scrolled using a scroll button.
#   """
#   @type scroll_state ::
#           :idle
#           | :dragging
#           | :scrolling

#   @typedoc """
#   The state with which the scrollable components GenServer is running.
#   """
#   @type t :: %__MODULE__{
#           id: atom,
#           graph: Graph.t(),
#           scroll_position: v2,
#           content_size: content_size,
#           scroll_state: scroll_state,
#           pid: pid,
#           horizontal_scroll_bar_pid: {:some, pid} | :none,
#           vertical_scroll_bar_pid: {:some, pid} | :none
#         }

#   defstruct id: :scroll_bars,
#             graph: Graph.build(),
#             scroll_position: {0, 0},
#             content_size: {0, 0},
#             scroll_state: :idle,
#             pid: nil,
#             horizontal_scroll_bar_pid: :none,
#             vertical_scroll_bar_pid: :none

#   @default_id :scroll_bars
#   @default_thickness 10

#   # PUBLIC API

#   @doc """
#   Find the direction the content should be scrolling in, depending on the scroll bar buttons pressed states.
#   """
#   @spec direction(t) :: v2
#   def direction(state) do
#     {x, _} =
#       state.horizontal_scroll_bar_pid
#       |> OptionEx.map(&ScrollBar.direction/1)
#       |> OptionEx.or_else({0, 0})

#     {_, y} =
#       state.vertical_scroll_bar_pid
#       |> OptionEx.map(&ScrollBar.direction/1)
#       |> OptionEx.or_else({0, 0})

#     {x, y}
#   end

#   @doc """
#   Find out if one of the scroll bars is currently being dragged.
#   """
#   @spec dragging?(t) :: boolean
#   def dragging?(%{scroll_state: :dragging}), do: true

#   def dragging?(_), do: false

#   @doc """
#   Find out if one of the scroll bars wheel is currently being scrolled.
#   """
#   @spec wheel_scrolling?(t) :: boolean
#   def wheel_scrolling?(%{wheel_state: :scrolling}), do: true

#   def wheel_scrolling?(_), do: false

#   @doc """
#   Find the latest position the scrollable content should be updated with.
#   The position corresponds to the contents translation, rather than the scroll bars drag control translation.
#   """
#   @spec new_position(t) :: {:some, v2} | :none
#   def new_position(%{scroll_position: position}), do: {:some, position}

#   # CALLBACKS

#   @impl Scenic.Scene
#   def init(scene, settings, opts) do
#     id = opts[:id] || @default_id
#     styles = Enum.into(opts || %{}, [])
#     shared_styles = Keyword.take(styles, [:scroll_bar, :scroll_drag])

#     horizontal_bar_styles =
#       (styles[:horizontal_scroll_bar] || styles[:scroll_bar])
#       |> OptionEx.return()
#       |> OptionEx.map(&Keyword.merge(&1, shared_styles))
#       |> OptionEx.map(&Keyword.put(&1, :id, :horizontal_scroll_bar))
#       |> OptionEx.map(&Keyword.put(&1, :translate, {0, settings.height}))

#     vertical_bar_styles =
#       (styles[:vertical_scroll_bar] || styles[:scroll_bar])
#       |> OptionEx.return()
#       |> OptionEx.map(&Keyword.merge(&1, shared_styles))
#       |> OptionEx.map(&Keyword.put(&1, :id, :vertical_scroll_bar))
#       |> OptionEx.map(&Keyword.put(&1, :translate, {settings.width, 0}))

#     {content_width, content_height} = settings.content_size
#     {x, y} = settings.scroll_position

#     graph = Graph.build()

#     graph =
#       horizontal_bar_styles
#       |> OptionEx.map(fn styles ->
#         graph
#         |> FloUI.Scrollable.ScrollBar.add_to_graph(
#           %{
#             width: settings.width,
#             height: styles[:scroll_bar_thickness] || @default_thickness,
#             content_size: content_width,
#             scroll_position: x,
#             direction: :horizontal
#           },
#           styles
#         )
#       end)
#       |> OptionEx.or_else(graph)

#     graph =
#       vertical_bar_styles
#       |> OptionEx.map(fn styles ->
#         graph
#         |> FloUI.Scrollable.ScrollBar.add_to_graph(
#           %{
#             width: styles[:scroll_bar_thickness] || @default_thickness,
#             height: settings.height,
#             content_size: content_height,
#             scroll_position: y,
#             direction: :vertical
#           },
#           styles
#         )
#       end)
#       |> OptionEx.or_else(graph)

#     state = %__MODULE__{
#       id: id,
#       graph: graph,
#       scroll_position: {x, y},
#       content_size: {content_width, content_height},
#       pid: self()
#     }

#     scene =
#       scene
#       |> assign(state: state)
#       |> push_graph(state.graph)

#     send_parent_event(scene, {:scroll_bars_initialized, state.id, state})

#     {:ok, scene}
#   end

#   @impl Scenic.Component
#   def validate(
#         %{
#           content_size: {content_x, content_y},
#           scroll_position: {x, y}
#         } = settings
#       )
#       when is_number(content_x) and is_number(content_y) and is_number(x) and is_number(y) do
#     {:ok, settings}
#   end

#   def validate(_), do: :invalid_input

#   @impl Scenic.Scene
#   def handle_event(
#         {:scroll_bar_initialized, :horizontal_scroll_bar, scroll_bar_state},
#         _from,
#         %{assigns: %{state: state}} = scene
#       ) do
#     state = %{state | horizontal_scroll_bar_pid: OptionEx.return(scroll_bar_state.pid)}
#     {:noreply, assign(scene, state: state)}
#   end

#   def handle_event(
#         {:scroll_bar_initialized, :vertical_scroll_bar, scroll_bar_state},
#         _from,
#         %{assigns: %{state: state}} = scene
#       ) do
#     state = %{state | vertical_scroll_bar_pid: OptionEx.return(scroll_bar_state.pid)}
#     {:noreply, assign(scene, state: state)}
#   end

#   def handle_event(
#         {:scroll_bar_button_pressed, _, scroll_bar_state},
#         _from,
#         %{assigns: %{state: state}} = scene
#       ) do
#     state = update_scroll_state(state, scroll_bar_state)
#     {:cont, {:scroll_bars_button_pressed, state.id, state}, assign(scene, state: state)}
#   end

#   def handle_event(
#         {:scroll_bar_button_released, _, scroll_bar_state},
#         _from,
#         %{assigns: %{state: state}} = scene
#       ) do
#     state = update_scroll_state(state, scroll_bar_state)

#     {:cont, {:scroll_bars_button_released, state.id, state, scroll_bar_state.wheel_state},
#      assign(scene, state: state)}
#   end

#   def handle_event(
#         {:cursor_scroll_started, _, scroll_bar_state},
#         _from,
#         %{assigns: %{state: state}} = scene
#       ) do
#     state = update_scroll_state(state, scroll_bar_state)

#     {:cont, {:cursor_scroll_started, state.id, state, scroll_bar_state.wheel_state},
#      assign(scene, state: state)}
#   end

#   def handle_event(
#         {:cursor_scroll_stopped, _, scroll_bar_state},
#         _from,
#         %{assigns: %{state: state}} = scene
#       ) do
#     state = update_scroll_state(state, scroll_bar_state)

#     {:cont, {:cursor_scroll_stopped, state.id, state, scroll_bar_state.wheel_state},
#      assign(scene, state: state)}
#   end

#   def handle_event(
#         {:scroll_bar_position_change, _, _scroll_bar_state},
#         _from,
#         %{assigns: %{state: %{scroll_state: :scrolling} = state}} = scene
#       ) do
#     {:noreply, scene}
#   end

#   def handle_event(
#         {:scroll_bar_position_change, _, %{direction: direction} = scroll_bar_state},
#         _from,
#         %{assigns: %{state: state}} = scene
#       ) do
#     {x, y} = state.scroll_position

#     state =
#       ScrollBar.new_position(scroll_bar_state)
#       |> Direction.from_vector_2(direction)
#       |> Direction.map_horizontal(&{&1, y})
#       |> Direction.map_vertical(&{x, &1})
#       |> Direction.unwrap()
#       |> (&Map.put(state, :scroll_position, &1)).()
#       |> update_scroll_state(scroll_bar_state)

#     {:cont, {:scroll_bars_position_change, state.id, state}, assign(scene, state: state)}
#   end

#   def handle_event(
#         {:scroll_bar_scroll_end, _id, scroll_bar_state},
#         _from,
#         %{assigns: %{state: state}} = scene
#       ) do
#     state = update_scroll_state(state, scroll_bar_state)

#     {:cont, {:scroll_bars_scroll_end, state.id, state}, assign(scene, state: state)}
#   end

#   def handle_event(_event, _from, scene) do
#     {:noreply, scene}
#   end

#   # no callback on the `Scenic.Scene` and no GenServer @behaviour, so impl will not work
#   @spec handle_call(request :: term(), GenServer.from(), state :: term()) ::
#           {:reply, reply :: term(), new_state :: term()}
#   def handle_call({:update_scroll_position, {x, y}}, _, %{assigns: %{state: state}} = scene) do
#     state = %{state | scroll_position: {x, y}}
#     # TODO error handling
#     state.horizontal_scroll_bar_pid
#     |> OptionEx.map(fn pid -> GenServer.call(pid, {:update_scroll_position, x}) end)

#     state.vertical_scroll_bar_pid
#     |> OptionEx.map(fn pid -> GenServer.call(pid, {:update_scroll_position, y}) end)

#     {:reply, :ok, assign(scene, state: state)}
#   end

#   def handle_call({:update_scroll_pos, {x, y}}, _, %{assigns: %{state: state}} = scene) do
#     state = %{state | scroll_position: {x, y}}
#     # TODO error handling
#     state.horizontal_scroll_bar_pid
#     |> OptionEx.map(fn pid -> GenServer.call(pid, {:update_scroll_position, x}) end)

#     state.vertical_scroll_bar_pid
#     |> OptionEx.map(fn pid -> GenServer.call(pid, {:update_scroll_position, y}) end)

#     {:reply, :ok, assign(scene, state: state)}
#   end

#   def handle_call({:update_content_size, {width, height}}, _, %{assigns: %{state: state}} = scene) do
#     state = %{state | content_size: {width, height}}

#     state.horizontal_scroll_bar_pid
#     |> OptionEx.map(fn pid -> GenServer.call(pid, {:update_content_size, width}) end)

#     state.vertical_scroll_bar_pid
#     |> OptionEx.map(fn pid -> GenServer.call(pid, {:update_content_size, height}) end)

#     {:reply, :ok, assign(scene, state: state)}
#   end

#   def handle_call(msg, _, scene) do
#     {:reply, {:error, {:unexpected_message, msg}}, scene}
#   end

#   def handle_cast({:update_cursor_scroll, scroll_pos}, %{assigns: %{state: state}} = scene) do
#     # TODO error handling
#     state.horizontal_scroll_bar_pid
#     |> OptionEx.map(fn pid -> GenServer.cast(pid, {:update_cursor_scroll, scroll_pos}) end)

#     state.vertical_scroll_bar_pid
#     |> OptionEx.map(fn pid -> GenServer.cast(pid, {:update_cursor_scroll, scroll_pos}) end)

#     {:noreply, scene}
#   end

#   def handle_cast(:unrequest_cursor_scroll, %{assigns: %{state: state}} = scene) do
#     # TODO error handling
#     state.horizontal_scroll_bar_pid
#     |> OptionEx.map(fn pid -> GenServer.cast(pid, :unrequest_cursor_scroll) end)

#     state.vertical_scroll_bar_pid
#     |> OptionEx.map(fn pid -> GenServer.cast(pid, :unrequest_cursor_scroll) end)

#     {:noreply, scene}
#   end

#   # UTILITY

#   @spec update_scroll_state(t, ScrollBar.t()) :: t
#   defp update_scroll_state(state, scroll_bar_state) do
#     %{state | scroll_state: scroll_bar_state.scroll_state}
#   end
# end
