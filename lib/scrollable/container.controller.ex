defmodule FloUI.Scrollable.ScrollableContainerController do
  import Scenic.Primitives, only: [group: 3]
  import FloUI.Scrollable.ScrollBar, only: [scroll_bar: 3]
  alias Scenic.Graph
  alias Scenic.Primitive
  alias Scenic.Math.Vector2

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
            frame: %{x: x, y: y, width: width, height: height}
          }
        } = scene
      ) do
    graph =
      graph
      |> group(
        fn g ->
          group(g, &render_children(&1, children), id: :content)
        end,
        scissor: {width, height},
        translate: {x, y},
        id: :content_container
      )

    Scenic.Scene.assign(scene, graph: graph)
  end

  def render_children(g, children) do
    Enum.reduce(children, g, fn child, g ->
      g |> child[:module].add_to_graph(child[:data], child[:opts])
    end)
  end
end
