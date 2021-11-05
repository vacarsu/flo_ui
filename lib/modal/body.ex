defmodule FloUI.Modal.Body do
  @moduledoc false

  use SnapFramework.Component,
    name: :modal_body,
    template: "lib/modal/body.eex",
    controller: :none,
    assigns: [
      width: 500,
      height: 500,
      show_check: true,
      show_close: true
    ],
    opts: []

  defcomponent :modal_body, :any

  def setup(%{assigns: %{opts: opts}} = scene) do
    assign(scene,
      width: opts[:width] || 500,
      height: opts[:height] || 500
    )
  end
end
