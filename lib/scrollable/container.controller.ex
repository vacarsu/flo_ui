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

    Scenic.Scene.assign(scene, graph: graph)
  end

  def on_scroll_position_change(%{assigns: %{content: %{x: x, y: y}}} = scene) do
    graph =
      scene.assigns.graph
      |> Graph.modify(
        :content,
        &Primitive.put_transform(&1, :translate, Vector2.add(scene.assigns.scroll_position, {x, y}))
      )
      |> Graph.modify(
        :vertical_scroll_bar,
        &scroll_bar(
          &1,
          %{
            scroll_position: Vector2.sub(scene.assigns.scroll_position, {x, y})
          },
          []
        )
      )
      |> Graph.modify(
        :horizontal_scroll_bar,
        &scroll_bar(
          &1,
          %{
            scroll_position: Vector2.sub(scene.assigns.scroll_position, {x, y})
          },
          []
        )
      )

    Scenic.Scene.assign(scene, graph: graph)
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
    |> Scenic.Scene.push_graph(graph)
  end

  def render_children(g, children) do
    Enum.reduce(children, g, fn child, g ->
      g |> child[:module].add_to_graph(child[:data], child[:opts])
    end)
  end
end
