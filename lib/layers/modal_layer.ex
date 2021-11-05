# defmodule FloUI.Layer.ModalLayer do
#   use Scenic.Component
#   alias Scenic.Graph

#   @viewport Application.get_env(:flo_ui, :modal_layer_size)
#   @center_x  elem(@viewport, 0) / 2
#   @center_y elem(@viewport, 1) / 2
#   @graph Graph.build()

#   def verify(data) when is_nil(data), do: {:ok, data}
#   def verify(data) when not is_nil(data), do: :invalid_data

#   def init(_, _) do
#     state = %{
#       graph: @graph,
#       components: %{}
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

#   defp render_component(%{graph: graph} = state, comp, data, opts) do
#     width = opts[:width]
#     height = opts[:height]
#     x = @center_x - width / 2
#     y = @center_y - height / 2
#     graph
#     |>  comp.add_to_graph(data, [translate: {x, y}, id: opts[:id]])
#     |> (&%{state | graph: &1}).()
#   end

#   defp delete_component(%{graph: graph} = state, id) do
#     graph
#     |>  Graph.delete(id)
#     |> (&%{state | graph: &1}).()
#   end
# end
