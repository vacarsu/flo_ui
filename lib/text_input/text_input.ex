defmodule FloUI.Component.TextInput do
  alias Scenic.Graph

  @moduledoc """
  ## Usage in SnapFramework

  Renders a text input with optional clear button. See Scenic.Component.TextField for more styles.

  ``` elixir
  <%= component FloUI.Component.TextInput,
      @text,
      id: :input,
      show_clear: true
  %>
  ```
  """

  @default_font_size 22
  @char_width 10
  @default_hint_color :light_grey

  @default_width @char_width * 24
  @default_height @default_font_size * 1.5

  use SnapFramework.Component,
    name: :text_input,
    template: "lib/text_input/text_input.eex",
    controller: FloUI.Component.TextInputController,
    assigns: [],
    opts: []

  defcomponent(:text_input, :string)

  use_effect([assigns: [data: :any]],
    run: [:on_data_change]
  )

  use_effect([assigns: [clear_hidden: :any]],
    run: [:on_clear_hidden_change]
  )

  def setup(%{assigns: %{opts: opts}} = scene) do
    assign(scene,
      id: scene.assigns.opts[:id],
      value: scene.assigns.data,
      hint: opts[:hint] || "",
      hint_color: opts[:hint_color],
      width: opts[:width] || opts[:w] || @default_width,
      height: opts[:height] || opts[:h] || @default_height,
      type: opts[:type] || :all,
      filter: opts[:filter] || nil,
      show_clear: opts[:show_clear] || false
    )
  end

  def bounds(_data, opts) do
    {0.0, 0.0, opts[:width] || opts[:w] || @default_width,
     opts[:height] || opts[:h] || @default_height}
  end

  def process_update(data, opts, scene) do
    {:noreply, assign(scene, data: data, value: data, opts: opts)}
  end

  def process_event({:value_changed, :text_input, value}, _, %{assigns: %{id: id}} = scene) do
    {:cont, {:value_changed, id, value}, assign(scene, value: value)}
  end

  def process_event({:click, :btn_clear}, _, %{assigns: %{id: id}} = scene) do
    Scenic.Scene.update_child(scene, :text_input, "", [])

    scene =
      scene
      |> assign(data: "")

    {:cont, {:value_changed, id, ""}, scene}
  end
end
