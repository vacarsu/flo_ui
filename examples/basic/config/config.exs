# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :scenic, :assets, module: FloUI.Assets

config :scenic, :themes, module: FloUI.Themes

# config :scenic, :assets,
#   module: Basic.Assets,
#   alias: []

# Configure the main viewport for the Scenic application
config :basic, :viewport,
  name: :main_viewport,
  size: {700, 600},
  theme: {:flo_ui, :primary},
  default_scene: Basic.Scene.Home,
  drivers: [
    [
      module: Scenic.Driver.Local,
      name: :glfw,
      on_close: :stop_system,
      window: [
        title: "flo ui examples",
        resizeable: false
      ]
    ]
  ]

config :flo_ui, :modal_layer_size, {700, 600}
config :flo_ui, :dropdown_layer_size, {700, 600}

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "prod.exs"
