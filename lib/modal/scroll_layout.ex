# defmodule FloUI.Modal.ScrollLayout do
#   @moduledoc """
#   ## Usage in SnapFramework

#   Scrolling layout modal component. Great for displaying content within a modal that needs to scroll.

#   data is a tuple in the form of ` elixir {label, component, component_data, component_opts}`

#   style opts
#     `width: :integer`
#     `height: :integer`
#     `frame_width: :integer`
#     `frame_height: :integer`
#     `content_height: :integer`
#     `content_width: :integer`
#     `show_check: :boolean`
#     `show_close: :boolean`

#   ``` elixir
#   <%= graph font_size: 20 %>

#   <%= component FloUI.Modal.ScrollLayout,
#       {"Label", FloUI.SelectionList, {@selection_list, @selected}, [id: :project_list]},
#       id: :scroll_layout,
#       width: 500,
#       height: 520,
#       frame_width: 480,
#       frame_height: 500,
#       content_width: 480,
#       content_height: @content_height,
#       show_check: true,
#       show_close: true
#   %>
#   ```
#   """

#   use Scenic.Component

#   alias Scenic.Graph

#   import Scenic.Primitives

#   alias FloUI.Theme
#   alias FloUI.Modal.Body
#   alias FloUI.Modal.Header
#   import FloUI.Scrollable.Components

#   @graph Graph.build(font_size: 16)

#   def validate(nil), do: :invalid_data
#   def validate(data), do: {:ok, data}

#   def init(scene, {title, cmp, data, cmp_opts}, opts) do
#     scene =
#       assign(scene,
#         graph: @graph,
#         title: title,
#         component: cmp,
#         component_data: data,
#         component_opts: cmp_opts,
#         width: opts[:width] || 500,
#         height: opts[:height] || 500,
#         frame_width: opts[:frame_width] || 480,
#         frame_height: opts[:frame_height] || 500,
#         content_width: opts[:content_width] || 500,
#         content_height: opts[:content_height] || 500,
#         show_check: opts[:show_check] || false,
#         show_close: opts[:show_close] || false
#       )
#       |> render_layout

#     {:ok, scene}
#   end

#   def handle_event({:click, :btn_check}, _from, scene) do
#     send_parent_event(scene, :modal_done)
#     {:noreply, scene}
#   end

#   def handle_event({:click, :btn_close}, _from, scene) do
#     send_parent_event(scene, :modal_close)
#     {:noreply, scene}
#   end

#   def handle_event(event, _, scene) do
#     {:cont, event, scene}
#   end

#   defp render_layout(
#          %{
#            assigns: %{
#              graph: graph,
#              title: title,
#              component: cmp,
#              component_data: cmp_data,
#              component_opts: cmp_opts,
#              width: width,
#              height: height,
#              frame_width: frame_width,
#              frame_height: frame_height,
#              content_width: content_width,
#              content_height: content_height,
#              show_check: show_check,
#              show_close: show_close
#            }
#          } = scene
#        ) do
#     graph =
#       graph
#       |> Body.add_to_graph(nil, translate: {0, 50}, width: width, height: height)
#       |> scrollable(
#         %{
#           frame: {frame_width, frame_height},
#           content: %{x: 0, y: 10, width: content_width, height: content_height}
#         },
#         &cmp.add_to_graph(&1, cmp_data, cmp_opts),
#         id: :scroll_box,
#         translate: {0, 60},
#         vertical_scroll_bar: [
#           scroll_buttons: true,
#           scroll_bar_theme: Scenic.Primitive.Style.Theme.preset(:dark),
#           scroll_bar_thickness: 15
#         ]
#       )
#       |> Header.add_to_graph(title, width: width, show_check: show_check, show_close: show_close)

#     assign(scene, graph: graph)
#     |> push_graph(graph)
#   end
# end
