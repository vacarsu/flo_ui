defmodule FloUI.Modal.Background do
  @moduledoc """
  ## Usage in SnapFramework

  Render this behind a modal if you want to block input to primitive render under it.

  <%= component FloUI.Modal.Background,
      nil,
      id: :modal_background
  %>
  """

  use SnapFramework.Component,
    name: :background,
    template: "lib/modal/background.eex",
    controller: :none,
    assigns: [width: 0, height: 0],
    opts: []

  defcomponent :background, :any
end
