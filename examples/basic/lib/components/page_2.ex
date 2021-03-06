defmodule Basic.Component.Page2 do
  import FloUI.Component.TextInput, only: [text_input: 3]

  use SnapFramework.Component,
    name: :page_2_scene,
    template: "lib/components/page_2.eex",
    controller: Basic.Component.Page2Controller,
    assigns: [input_value: "Test"],
    opts: []

  defcomponent(:page_2, :any)

  def process_event({:value_changed, :text_input, value}, _, scene) do
    Logger.debug("input value changed #{inspect(value)}")
    {:noreply, assign(scene, input_value: value)}
  end
end
