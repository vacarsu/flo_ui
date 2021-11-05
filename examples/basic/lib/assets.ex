defmodule Basic.Assets do
  use Scenic.Assets.Static,
    otp_app: :basic,
    sources: [
      {:scenic, "deps/scenic/assets"},
      {:flo_ui, "assets"}
    ]
end
