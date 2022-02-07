defmodule Basic.Component.Page3 do
  use SnapFramework.Component,
    name: :page_3,
    template: "lib/components/page_3.eex",
    controller: Basic.Component.Page3Controller,
    assigns: [input_value: "Test"],
    opts: []

  def process_event(event, _, scene) do
    {:noreply, scene}
  end
end
