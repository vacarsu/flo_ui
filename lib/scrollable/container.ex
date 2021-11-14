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
  alias FloUI.Scrollable.Drag
  alias FloUI.Scrollable.Wheel
  alias FloUI.Scrollable.Acceleration
  alias FloUI.Scrollable.PositionCap

  use SnapFramework.Component,
    name: :scrollable_container,
    template: "lib/scrollable/container.eex",
    controller: FloUI.Scrollable.ScrollableContainerController,
    assigns: [],
    opts: []

  defcomponent(:scrollable_container, :map)

  @default_position {0, 0}
  @default_fps 30

  use_effect([assigns: [scroll_position: :any]],
    run: [:on_scroll_position_change]
  )

  def setup(%{assigns: %{data: data, opts: opts}} = scene) do
    {content_width, content_height} = data.content
    {frame_width, frame_height} = data.frame
    {frame_x, frame_y} = opts[:translate] || @default_position
    scroll_position = opts[:scroll_position] || @default_position

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
          drag_state: nil,
          scroll_buttons: %{
            scroll_button_1: :released,
            scroll_button_2: :released
          },
          pid: nil
        },
        horizontal: %{
          scrolling: :idle,
          wheel_state: nil,
          drag_state: nil,
          scroll_buttons: %{
            scroll_button_1: :released,
            scroll_button_2: :released
          },
          pid: nil
        }
      },
      scroll_bars: opts[:scroll_bars]
    )
    |> init_position_caps
  end

  def mounted(scene) do
    FloUI.Scrollable.ScrollableContainerController.render_content(scene)
  end

  def bounds(%{frame: {x, y}} = data, _opts) do
    {0.0, 0.0, x, y}
  end

  def process_event(
        {:register_scroll_bar, direction, scroll_bar_state},
        pid,
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

  def process_event({:drag_changed, direction, scroll_bar_state}, _, scene) do
    scene =
      scene
      |> assign(
        scroll_bars_state: Map.update!(
          scene.assigns.scroll_bars_state,
          direction, fn _ ->
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

  def process_event({:update_scroll_position, :horizontal, {x, _}}, _, scene) do
    {_, y} = scene.assigns.scroll_position
    {:noreply, assign(scene, scroll_position: PositionCap.cap(scene.assigns.position_caps, {x, y}))}
  end

  def process_event({:update_scroll_position, pos}, _, scene) do
    {:noreply, assign(scene, scroll_position: PositionCap.cap(scene.assigns.position_caps, pos))}
  end

  def process_event(event, _, scene) do
    {:cont, event, scene}
  end

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

  def process_info(:tick, scene) do
    {:noreply, assign(scene, animating: false) |> update}
  end

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
      scroll_position: PositionCap.cap(position_cap, scene.assigns.scroll_position)
    )
  end

  defp update(scene) do
    scene
    |> apply_force
    |> verify_cooling_down
    |> tick
  end

  @spec verify_cooling_down(Scenic.Scene) :: Scenic.Scene
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
          scroll_position: scroll_position,
          scroll_bars_state: %{
            vertical: %{
              scrolling: :dragging,
              drag_state: drag_state
            },
          }
        }
      } = scene
    ) do
    {_, y} = Drag.new_position(drag_state) |> Vector2.invert()
    {x, _} = scroll_position

    scroll_position =
      {x, y}
      |> Vector2.add({scene.assigns.content.x, scene.assigns.content.y})

    assign(scene, scroll_position: PositionCap.cap(scene.assigns.position_caps, scroll_position))
  end

  defp apply_force(
      %{
        assigns: %{
          scroll_position: scroll_position,
          scroll_bars_state: %{
            horizontal: %{
              scrolling: :dragging,
              drag_state: drag_state
            },
          }
        }
      } = scene
    ) do
    {x, _} = Drag.new_position(drag_state) |> Vector2.invert()
    {_, y} = scroll_position

    scroll_position =
      {x, y}
      |> Vector2.add({scene.assigns.content.x, scene.assigns.content.y})

    assign(scene, scroll_position: PositionCap.cap(scene.assigns.position_caps, scroll_position))
  end

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

  defp tick_time(%{assigns: %{fps: fps}}) do
    trunc(1000 / fps)
  end
end
