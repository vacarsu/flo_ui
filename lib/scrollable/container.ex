defmodule FloUI.Scrollable.Container do
  @moduledoc """
  ## Usage in SnapFramework

  Scrollable container is used for large content that you want to scroll. It renders a component child within.
  this is meant to be as plug and play as possible. With minimal fiddling to get it to work.
  You can use the ScrollBar component directly if you want to build your own scrollable containers.

  data is an object in the form of

  ``` elixir
  %{
    frame: {460, 470},
    content: {800, 800}
  }
  ```

  You can choose which scroll bars to render via the `scroll_bars` option.

  ``` elixir
  <%= graph font_size: 20 %>

  <%= component FloUI.Scrollable.Container,
        %{
            frame: {460, 470},
            content: {800, 800}
        },
        translate: {20, 60},
        scroll_bars: %{
            vertical: %{
                show: true,
                show_buttons: true,
                theme: Scenic.Primitive.Style.Theme.preset(:dark),
                thickness: 15
            },
            horizontal: %{
                show: true,
                show_buttons: true,
                theme: Scenic.Primitive.Style.Theme.preset(:dark),
                thickness: 15
            }
        } do %>

        <%= component Basic.Component.Page4, nil %>

    <% end %>
  ```
  """

  alias Scenic.Graph
  alias Scenic.Math.Vector2

  alias FloUI.Scrollable.Hotkeys
  alias FloUI.Scrollable.Direction
  alias FloUI.Scrollable.Acceleration
  alias FloUI.Scrollable.PositionCap

  use SnapFramework.Component,
    name: :scrollable_container,
    template: "lib/scrollable/container.eex",
    controller: FloUI.Scrollable.ScrollableContainerController,
    assigns: [],
    opts: []

  defcomponent(:scrollable_container, :map)

  @default_horizontal_scroll_bar %{
    show: false,
    show_buttons: false,
    thickness: 15,
    radius: 3,
    theme: FloUI.Theme.preset(:scrollbar)
  }
  @default_vertical_scroll_bar %{
    show: true,
    show_buttons: true,
    thickness: 15,
    radius: 3,
    theme: FloUI.Theme.preset(:scrollbar)
  }
  @default_position {0, 0}
  @default_fps 30

  use_effect([assigns: [scroll_position: :any]],
    run: [:on_scroll_position_change]
  )

  @impl true
  def setup(%{assigns: %{data: data, opts: opts}} = scene) do
    {content_width, content_height} = data.content
    {frame_width, frame_height} = data.frame
    {frame_x, frame_y} = opts[:translate] || @default_position
    scroll_position = Map.get(data, :scroll_position, {0, 0})
    scroll_bars =
      case opts[:scroll_bars] do
        nil ->
          %{vertical: @default_vertical_scroll_bar, horizontal: @default_horizontal_scroll_bar}
        scroll_bars ->
          vertical = Map.get(scroll_bars, :vertical, @default_vertical_scroll_bar)
          horizontal = Map.get(scroll_bars, :horizontal, @default_horizontal_scroll_bar)
          %{
            vertical: %{
              show: Map.get(vertical, :show, true),
              show_buttons: Map.get(vertical, :show_buttons, true),
              thickness: Map.get(vertical, :thickness, 15),
              radius: Map.get(vertical, :radius, 3),
              theme: Map.get(vertical, :theme, FloUI.Theme.preset(:scrollbar))
            },
            horizontal: %{
              show: Map.get(horizontal, :show, true),
              show_buttons: Map.get(horizontal, :show_buttons, true),
              thickness: Map.get(horizontal, :thickness, 15),
              radius: Map.get(horizontal, :radius, 3),
              theme: Map.get(horizontal, :theme, FloUI.Theme.preset(:scrollbar))
            }
          }
      end

    assign(scene,
      id: opts[:id] || :scrollable,
      theme: opts[:theme] || FloUI.Theme.preset(:scrollbar),
      frame: %{x: frame_x, y: frame_y, width: frame_width, height: frame_height},
      content: %{x: 0, y: 0, width: content_width, height: content_height},
      scroll_position: Vector2.add(scroll_position, {0, 0}),
      fps: opts[:scroll_fps] || @default_fps,
      acceleration: Acceleration.init(opts[:scroll_acceleration]),
      hotkeys: Hotkeys.init(opts[:scroll_hotkeys]),
      scroll_direction: nil,
      scroll_bars_state: %{
        vertical: %{
          scrolling: :idle,
          wheel_state: nil,
          scroll_buttons: %{
            scroll_button_1: :released,
            scroll_button_2: :released
          },
          pid: nil
        },
        horizontal: %{
          scrolling: :idle,
          wheel_state: nil,
          scroll_buttons: %{
            scroll_button_1: :released,
            scroll_button_2: :released
          },
          pid: nil
        }
      },
      scroll_bars: scroll_bars
    )
    |> init_position_caps
  end

  @impl true
  def mounted(scene) do
    scene =
      FloUI.Scrollable.ScrollableContainerController.render_content(scene)

    Scenic.Scene.push_graph(scene, scene.assigns.graph)
  end

  @impl true
  def bounds(%{frame: {x, y}}, _opts) do
    {0.0, 0.0, x, y}
  end

  @impl true
  def process_update(data, _opts, scene) do
    scene =
      assign(scene,
        data: data,
        scroll_position: PositionCap.cap(scene.assigns.position_caps, Vector2.invert(data.scroll_position))
      )

    {:noreply, scene}
  end

  @impl true
  def process_event(
        {:register_scroll_bar, direction, scroll_bar_state},
        _pid,
        %{assigns: %{scroll_bars_state: scroll_bars_state}} = scene
      ) do
    scene =
      scene
      |> assign(
        scroll_bars_state:
          Map.update!(scroll_bars_state, direction, fn _ ->
            scroll_bar_state
          end)
      )

    {:noreply, scene}
  end

  def process_event({:scroll_bar_state_changed, direction, scroll_bar_state}, _, scene) do
    scene =
      scene
      |> assign(
        scroll_bars_state: Map.update!(
          scene.assigns.scroll_bars_state,
          direction, fn _ ->
            scroll_bar_state
          end)
      )
      |> update

    {:noreply, scene}
  end

  def process_event({:update_scroll_position, :vertical, {_, y}}, _, scene) do
    {x, _} = scene.assigns.scroll_position
    {:noreply, assign(scene, scroll_position: PositionCap.cap(scene.assigns.position_caps, {x, y}))}
  end

  def process_event({:update_scroll_position, :horizontal, {_, x}}, _, scene) do
    {_, y} = scene.assigns.scroll_position
    {:noreply, assign(scene, scroll_position: PositionCap.cap(scene.assigns.position_caps, {x, y}))}
  end

  def process_event({:update_scroll_position, pos}, _, scene) do
    {:noreply, assign(scene, scroll_position: PositionCap.cap(scene.assigns.position_caps, pos))}
  end

  def process_event(event, _, scene) do
    {:cont, event, scene}
  end

  @impl true
  def process_input(
        {:cursor_scroll, scroll_pos},
        :input_capture,
        %{assigns: %{scroll_bars_state: scroll_bars_state}} = scene
      ) do
    if not is_nil(scroll_bars_state.vertical.pid) do
      GenServer.cast(scroll_bars_state.vertical.pid, {:update_cursor_scroll, scroll_pos})
    end

    if not is_nil(scroll_bars_state.horizontal.pid) do
      GenServer.cast(scroll_bars_state.horizontal.pid, {:update_cursor_scroll, scroll_pos})
    end

    {:noreply, scene}
  end

  @impl true
  def process_info(:tick, scene) do
    {:noreply, assign(scene, animating: false) |> update}
  end

  @spec init_position_caps(Scenic.Scene.t) :: Scenic.Scene.t
  defp init_position_caps(
         %{
           assigns: %{
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
      scroll_position: PositionCap.cap(position_cap, Vector2.invert(scene.assigns.scroll_position))
    )
  end

  @spec update(Scenic.Scene.t) :: Scenic.Scene.t
  defp update(scene) do
    scene
    |> apply_force
    |> verify_cooling_down
    |> tick
  end

  @spec verify_cooling_down(Scenic.Scene.t) :: Scenic.Scene.t
  defp verify_cooling_down(%{assigns: %{scroll_bars_state: %{vertical: vertical, horizontal: horizontal}}} = scene) do
    if vertical.scrolling == :idle and
       horizontal.scrolling == :idle and not
       Acceleration.is_stationary?(scene.assigns.acceleration)
    do
      assign(scene,
        scroll_bars_state: %{
          vertical: %{vertical | scrolling: :cooling_down},
          horizontal: %{horizontal | scrolling: :cooling_down}
        }
      )
    else
      if vertical.scrolling == :cooling_down and horizontal.scrolling == :cooling_down and Acceleration.is_stationary?(scene.assigns.acceleration) do
        assign(scene,
          scroll_bars_state: %{
            vertical: %{vertical | scrolling: :idle},
            horizontal: %{horizontal | scrolling: :idle}
          }
        )
      else
        scene
      end
    end
  end

  @spec apply_force(Scenic.Scene.t) :: Scenic.Scene.t
  defp apply_force(
         %{
           assigns: %{
             scroll_bars_state: %{
               vertical: %{
                 scrolling: :idle
               },
               horizontal: %{
                 scrolling: :idle
               }
            }
          }
        } = scene
      ), do: scene

  defp apply_force(
    %{
      assigns: %{
        scroll_bars_state: %{
        vertical: %{
          scrolling: vert_scroll,
          wheel_state: %{offset: {_, offset_y}}
        },
        horizontal: %{
          scrolling: horiz_scroll,
          wheel_state: %{offset: {_, offset_x}}
        }
      }
    }
  } = scene
) when vert_scroll == :wheel or horiz_scroll == :wheel do
    {x, y} = scene.assigns.scroll_position
    scroll_position = {x + offset_x * 5, y + offset_y * 5}

    assign(scene, scroll_position: PositionCap.cap(scene.assigns.position_caps, scroll_position))
  end

  defp apply_force(scene) do
    scroll_direction = get_scroll_direction(scene)
    force =
      Hotkeys.direction(scene.assigns.hotkeys)
      |> Vector2.add(scroll_direction)

    Acceleration.apply_force(scene.assigns.acceleration, force)
    |> Acceleration.apply_counter_pressure()
    |> (&assign(scene, acceleration: &1)).()
    |> (fn scene ->
          scroll_pos =
            Acceleration.translate(scene.assigns.acceleration, scene.assigns.scroll_position)

          assign(scene, scroll_position: PositionCap.cap(scene.assigns.position_caps, scroll_pos))
        end).()
  end

  @spec get_scroll_direction(Scenic.Scene.t) :: Scenic.Math.Vector2.t
  defp get_scroll_direction(%{assigns: %{scroll_bars_state: scroll_bars_state}}) do
    case scroll_bars_state do
      %{vertical: %{scroll_buttons: %{scroll_button_1: :pressed, scroll_button_2: :released}}} ->
        Direction.return(1, :vertical)
        |> Direction.to_vector_2()

      %{vertical: %{scroll_buttons: %{scroll_button_1: :released, scroll_button_2: :pressed}}} ->
        Direction.return(-1, :vertical)
        |> Direction.to_vector_2()

      %{horizontal: %{scroll_buttons: %{scroll_button_1: :pressed, scroll_button_2: :released}}} ->
        Direction.return(1, :horizontal)
        |> Direction.to_vector_2()

      %{horizontal: %{scroll_buttons: %{scroll_button_1: :released, scroll_button_2: :pressed}}} ->
        Direction.return(-1, :horizontal)
        |> Direction.to_vector_2()

      _ ->
        {0, 0}
    end
  end

  @spec tick(Scenic.Scene.t) :: Scenic.Scene.t
  defp tick(%{assigns: %{scroll_bars_state: %{vertical: %{scrolling: :idle}, horizontal: %{scrolling: :idle}}}} = scene), do: assign(scene, animating: false)

  defp tick(%{assigns: %{scroll_bars_state: %{vertical: %{scrolling: :dragging}}}} = scene) do
    assign(scene, animating: false)
  end

  defp tick(%{assigns: %{scroll_bars_state: %{horizontal: %{scrolling: :dragging}}}} = scene) do
    assign(scene, animating: false)
  end

  defp tick(%{assigns: %{scroll_bars_state: %{vertical: %{scrolling: vert_scrolling}, horizontal: %{scrolling: horiz_scrolling}}}} = scene)
    when vert_scrolling == :wheel or horiz_scrolling == :wheel
    do
      assign(scene, animating: false)
    end

  defp tick(%{assigns: %{animating: true}} = scene), do: scene

  defp tick(scene) do
    Process.send_after(self(), :tick, tick_time(scene))
    assign(scene, animating: true)
  end

  @spec tick_time(Scenic.Scene.t) :: integer
  defp tick_time(%{assigns: %{fps: fps}}) do
    trunc(1000 / fps)
  end
end
