defmodule FloUI do
  @moduledoc """
  ## Setup

  FloUI ships with a number of icon assets which much be pulled into your project.
  Place the following in your assets.ex file. Include scenic assets as well for the fonts.

  ``` elixir
  defmodule MyApp.Assets do
    use Scenic.Assets.Static,
      otp_app: :my_app,
      sources: [
        "assets",
        {:scenic, "deps/scenic/assets"},
        {:flo_ui, "deps/flo_ui/assets"}
      ]
  end
  ```

  Then in your config

  ``` elixir
  config :scenic, :assets, module: MyApp.Assets
  ```
  """
end
