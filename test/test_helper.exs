# dynamically update the config to point to the test assets
Application.put_env(:scenic, :assets, module: FloUI.Assets)

Application.put_env(:scenic, :themes, module: FloUI.TestThemes)

ExUnit.start()
