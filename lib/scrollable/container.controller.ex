defmodule FloUI.Scrollable.ScrollableContainerController do
  import Scenic.Primitives, only: [group: 3, rect: 3]
  import FloUI.Scrollable.ScrollBar, only: [scroll_bar: 3]
  alias Scenic.Graph
  alias Scenic.Primitive
  alias Scenic.Math.Vector2
  require Logger

  def on_scroll_position_change(
    %{
      assigns: %{
        scroll_position: scroll_position,
        scroll_bars_state: %{
          vertical: %{
            scrolling: vert_scrolling
          },
          horizontal: %{
            scrolling: horiz_scrolling
          }
        }
      }
    } = scene
  ) when vert_scrolling == :dragging or horiz_scrolling == :dragging do
    graph =
      scene.assigns.graph
      |> Graph.modify(
        :content,
        &Primitive.put_transform(&1, :translate, scroll_position)
      )

    Scenic.Scene.send_parent_event(scene, {:scroll_position_changed, Vector2.invert(scroll_position)})
    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_scroll_position_change(%{assigns: %{scroll_position: scroll_position, content: %{x: x, y: y}}} = scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(
        :content,
        &Primitive.put_transform(&1, :translate, Vector2.add(scroll_position, {x, y}))
      )
      |> Graph.modify(
        :vertical_scroll_bar,
        &scroll_bar(
          &1,
          %{
            scroll_position: Vector2.sub(scroll_position, {x, y})
          },
          []
        )
      )
      |> Graph.modify(
        :horizontal_scroll_bar,
        &scroll_bar(
          &1,
          %{
            scroll_position: Vector2.sub(scroll_position, {x, y})
          },
          []
        )
      )
    Scenic.Scene.send_parent_event(scene, {:scroll_position_changed, Vector2.invert(scroll_position)})
    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_frame_change(%{
    assigns: %{
      scroll_position: scroll_position,
      frame: %{
        x: fx,
        y: fy,
        width: f_width,
        height: f_height
      },
      content: %{
        width: c_width,
        height: c_height
      }
    }
  } = scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(:input_capture, &rect(&1, {f_width, f_height}, []))
      |> Graph.modify(:content, &Primitive.put_transform(&1, :translate, scroll_position))
      |> Graph.modify(:content_container, &Primitive.put_transform(&1, :translate, {fx, fy}))
      |> Graph.modify(:content_container, &Primitive.put_style(&1, :scissor, {f_width, f_height}))
      |> Graph.modify(:vertical_scroll_bar,
        &scroll_bar(&1,
          %{
            direction: :vertical,
            content_size: {c_width, c_height},
            width: scene.assigns.scroll_bars.vertical.thickness,
            height: f_height,
            scroll_position: scene.assigns.scroll_position
          },
          [translate: {f_width, 0}]
        )
      )

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_children_change(scene) do
    graph =
      scene.assigns.graph
      |> Graph.delete(:content_container)

    scene
    |> Scenic.Scene.assign(graph: graph)
    |> render_content
  end

  def render_content(
        %{
          assigns: %{
            children: children,
            graph: graph,
            frame: %{x: x, y: y, width: width, height: height},
            scroll_position: scroll_position
          }
        } = scene
      ) do
    graph =
      graph
      |> group(
        fn g ->
          group(g, &render_children(&1, children), id: :content, translate: scroll_position)
        end,
        scissor: {width, height},
        translate: {x, y},
        id: :content_container
      )

    Scenic.Scene.assign(scene, graph: graph)
  end

  def render_children(g, children) do
    SnapFramework.Engine.Builder.build_graph(children, g)
  end
end
