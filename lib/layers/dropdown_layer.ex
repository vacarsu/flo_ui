# defmodule FloUI.Layer.DropdownLayer do
#   use Scenic.Component
#   alias Scenic.Graph
#   alias Scenic.Math.Vector2

#   alias FloUI.Util.CursorPos

#   @viewport Application.get_env(:flo_ui, :dropdown_layer_size)
#   @center_x  elem(@viewport, 0) / 2
#   @center_y elem(@viewport, 1) / 2
#   @graph Graph.build()

#   def verify(data) when is_nil(data), do: {:ok, data}
#   def verify(data) when not is_nil(data), do: :invalid_data

#   def init(_, _) do
#     state = %{
#       graph: @graph,
#       components: %{},
#       cursor_pos: nil
#     }

#     {:ok, state, push: state.graph}
#   end

#   def filter_event({_event_id, cmp_id, _data} = event, _id, %{components: components} = state) do
#     forward_id = components[cmp_id]
#     send(forward_id, event)
#     {:noreply, state}
#   end

#   def filter_event({_event_id, cmp_id} = event, _id, %{components: components} = state) do
#     forward_id = components[cmp_id]
#     send(forward_id, event)
#     {:noreply, state}
#   end

#   def handle_info({:update_cursor_pos, cursor_pos}, state) do
#     state =
#       %{state | cursor_pos: cursor_pos}

#       {:noreply, state}
#   end

#   def handle_info({:render_component, {event_id, comp, data, opts}}, %{components: components} = state) do
#     state =
#       %{state |
#         components: Map.put_new(components, opts[:id], event_id)
#       }
#       |> render_component(comp, data, opts)

#       {:noreply, state, push: state.graph}
#   end

#   def handle_info({:delete_component, id}, %{components: components} = state) do
#     state =
#       %{state |
#         components: Map.delete(components, id)
#       }
#       |> delete_component(id)

#       {:noreply, state, push: state.graph}
#   end

#   defp render_component(%{graph: graph, cursor_pos: cursor_pos} = state, comp, data, opts) do
#     t_offset = opts[:t_offset] || {0, 0}
#     translate = Vector2.add(CursorPos.get, t_offset)
#     graph
#     |>  comp.add_to_graph(data, [translate: translate, id: opts[:id]])
#     |> (&%{state | graph: &1}).()
#   end

#   defp delete_component(%{graph: graph} = state, id) do
#     graph
#     |>  Graph.delete(id)
#     |> (&%{state | graph: &1}).()
#   end
# end
