defmodule FloUI.Icon do
  @moduledoc """
  ## Usage in SnapFramework

  Render an icon.

  data is a tuple representing the asset.

  <%= component FloUI.Icon,
      {:flo_ui, "path_to_asset"},
      id: :icon
  %>
  """

  use SnapFramework.Component,
    name: :icon_clear,
    template: "lib/icons/icon.eex",
    controller: :none,
    assigns: [],
    opts: []

  defcomponent :icon, :any
end
