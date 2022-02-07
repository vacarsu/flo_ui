defmodule Basic.Component.Page2 do
  use SnapFramework.Component,
    name: :page_2,
    template: "lib/components/page_2.eex",
    controller: Basic.Component.Page2Controller,
    assigns: [input_value: "Test"],
    opts: []

  def process_event({:value_changed, :text_input, value}, _, scene) do
    {:noreply, assign(scene, input_value: value)}
  end

  def process_event(_, _, scene) do
    {:noreply, scene}
  end
end
