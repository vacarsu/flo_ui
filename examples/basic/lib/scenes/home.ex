defmodule Basic.Scene.Home do
  import Scenic.Primitives, only: [text: 3]
  import FloUI.Tabs, only: [tabs: 3]
  import FloUI.Tab, only: [tab: 3]
  import Basic.Component.Page1, only: [page_1: 3]
  import Basic.Component.Page2, only: [page_2: 3]
  import Basic.Component.Page3, only: [page_3: 3]

  use SnapFramework.Scene,
    name: :home_scene,
    template: "lib/scenes/home.eex",
    controller: Basic.Scene.HomeController,
    assigns: [
      active_tab: Basic.Component.Page1,
      active_theme: {:flo_ui, :teal_dark},
      tabs: [
        {"page 1", Basic.Component.Page1},
        {"page 2", Basic.Component.Page2},
        {"page 3", Basic.Component.Page3},
        {"page 4", Basic.Component.Page4}
      ],
      theme_opts: [
        {{"base", {:flo_ui, :base}}, :base},
        {{"light", {:flo_ui, :light}}, :light},
        {{"dark", {:flo_ui, :dark}}, :dark},
        {{"scrollbar", {:flo_ui, :scrollbar}}, :scrollbar},
        {{"blue light", {:flo_ui, :blue_light}}, :blue_light},
        {{"blue dark", {:flo_ui, :blue_dark}}, :blue_dark},
        {{"red light", {:flo_ui, :red_light}}, :red_light},
        {{"red dark", {:flo_ui, :red_dark}}, :red_dark},
        {{"purple light", {:flo_ui, :purple_light}}, :purple_light},
        {{"purple dark", {:flo_ui, :purple_dark}}, :purple_dark},
        {{"amber light", {:flo_ui, :amber_light}}, :amber_light},
        {{"amber dark", {:flo_ui, :amber_dark}}, :amber_dark},
        {{"orange light", {:flo_ui, :orange_light}}, :orange_light},
        {{"orange dark", {:flo_ui, :orange_dark}}, :orange_dark},
        {{"teal light", {:flo_ui, :teal_light}}, :teal_light},
        {{"teal dark", {:flo_ui, :teal_dark}}, :teal_dark},
        {{"green light", {:flo_ui, :green_light}}, :green_light},
        {{"green dark", {:flo_ui, :green_dark}}, :green_dark},
        {{"cyan light", {:flo_ui, :cyan_light}}, :cyan_light},
        {{"cyan dark", {:flo_ui, :cyan_dark}}, :cyan_dark},
        {{"sky light", {:flo_ui, :sky_light}}, :sky_light},
        {{"sky dark", {:flo_ui, :sky_dark}}, :sky_dark},
        {{"emerald light", {:flo_ui, :emerald_light}}, :emerald_light},
        {{"emerald dark", {:flo_ui, :emerald_dark}}, :emerald_dark},
        {{"yellow light", {:flo_ui, :yellow_light}}, :yellow_light},
        {{"yellow dark", {:flo_ui, :yellow_dark}}, :yellow_dark}
      ]
    ]

  use_effect [assigns: [active_theme: :any]], [
    run: [:on_theme_change]
  ]

  def setup(scene) do
    scene
    |> assign(active_theme: scene.assigns.opts[:theme])
  end

  def process_input({:viewport, {:reshape, size}}, _, scene) do
    {:noreply, scene}
  end

  def process_event({:value_changed, :theme_dropdown, value}, _, scene) do
    {:noreply, assign(scene, active_theme: value)}
  end

  def process_event(_, _, scene) do
    {:noreply, scene}
  end

  def process_cast(_, scene) do
    {:noreply, scene}
  end
end
