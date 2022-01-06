defmodule FloUI.Modal.Layout do
  @moduledoc """
  ## Usage in SnapFramework

  Scrolling layout modal component. Great for displaying content within a modal.
  If the content needs to scroll within the modal, use FloUI.Modal.ScrollLayout.

  data is a `:string`

  style opts
    `width: :integer`
    `height: :integer`
    `show_check: :boolean`
    `show_close: :boolean`

  ``` elixir
  <%= graph font_size: 20 %>

  <%= component FloUI.Modal.Layout,
      "label",
      id: :scroll_layout,
      width: 500,
      height: 520,
      show_check: true,
      show_close: true
  %>
  ```
  """

  use SnapFramework.Component,
    name: :layout,
    template: "lib/modal/layout.eex",
    controller: :none,
    assigns: [
      width: 500,
      height: 500,
      show_check: true,
      show_close: true
    ],
    opts: []

  defcomponent(:layout, :string)

  @impl true
  def setup(%{assigns: %{opts: opts}} = scene) do
    assign(scene,
      width: opts[:width] || 500,
      height: opts[:height] || 500,
      show_check: opts[:show_check] || false,
      show_close: opts[:show_close] || false
    )
  end

  @impl true
  def handle_get(_from, scene) do
    {:reply, scene, scene}
  end

  @impl true
  def process_event({:click, :btn_check}, _from, scene) do
    send_parent_event(scene, :modal_done)
    {:noreply, scene}
  end

  def process_event({:click, :btn_close}, _from, scene) do
    send_parent_event(scene, :modal_close)
    {:noreply, scene}
  end

  def process_event(event, _from, scene) do
    {:cont, event, scene}
  end
end
