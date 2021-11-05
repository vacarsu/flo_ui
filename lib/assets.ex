defmodule FloUI.Assets do
  @moduledoc false

  use Scenic.Assets.Static,
    otp_app: :flo_ui,
    sources: [
      scenic: "deps/scenic/assets",
      flo_ui: "assets"
    ]
end
