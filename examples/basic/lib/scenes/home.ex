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
    controller: :none,
    assigns: [
      active_tab: Basic.Component.Page1,
      tabs: [
        {"page 1", Basic.Component.Page1},
        {"page 2", Basic.Component.Page2},
        {"page 3", Basic.Component.Page3},
        {"page 4", Basic.Component.Page4}
      ]
    ]

  def setup(scene) do
    scene
  end

  def process_input({:viewport, {:reshape, size}}, _, scene) do
    {:noreply, scene}
  end

  def process_cast(_, scene) do
    {:noreply, scene}
  end
end
