defmodule FloUI.Modal.Header do
  @moduledoc false

  use SnapFramework.Component,
    name: :modal_header,
    template: "lib/modal/header.eex",
    controller: :none,
    assigns: [
      width: 500,
      height: 500,
      show_check: true,
      show_close: true
    ],
    opts: []

  defcomponent(:modal_header, :string)

  def setup(%{assigns: %{opts: opts}} = scene) do
    assign(scene,
      width: opts[:width] || 500,
      height: opts[:height] || 500,
      show_check: opts[:show_check] || false,
      show_close: opts[:show_close] || false
    )
  end
end
