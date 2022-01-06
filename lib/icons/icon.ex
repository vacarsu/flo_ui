defmodule FloUI.Icon do
  @moduledoc """
  ## Usage in SnapFramework

  Render an icon.

  data is a tuple representing the asset.

  ``` elixir
  <%= component FloUI.Icon,
      {:flo_ui, "path_to_asset"},
      id: :icon
  %>
  ```
  """

  use SnapFramework.Component,
    name: :icon_clear,
    template: "lib/icons/icon.eex",
    controller: :none,
    assigns: [],
    opts: []

  defcomponent(:icon, :tuple)

  @impl true
  def bounds(_data, _opts) do
    {0.0, 0.0, 48, 48}
  end

  @impl true
  def handle_get(_from, scene) do
    {:reply, scene, scene}
  end
end
