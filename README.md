## Get Started

``` elixir
{:flo_ui, "~> 0.1.0-alpha"}
```

To use FloUI the first thing you must do is add the shipped assets to your assets module.

  ``` elixir
  defmodule MyApp.Assets do
    use Scenic.Assets.Static,
      otp_app: :my_app,
      sources: [
        "assets",                        # <- your assets
        {:scenic, "deps/scenic/assets"}, # <- scenic assets
        {:flo_ui, "deps/flo_ui/assets"}  # <- flo_ui assets
      ]
  end
  ```

  Then in your config

``` elixir
  config :scenic, :assets, module: MyApp.Assets
```

