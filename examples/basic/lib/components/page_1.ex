defmodule Basic.Component.Page1 do
  use SnapFramework.Component,
    name: :page_1,
    template: "lib/components/page_1.eex",
    controller: Basic.Component.Page1Controller,
    assigns: [
      btn_text: "Update Button",
      buttons: [
        "test 1",
        "test 2",
        "test 3",
        "test 4",
        "test 5"
      ]
    ],
    opts: []

  use_effect([assigns: [btn_text: :any]],
    run: [:on_btn_text_change]
  )

  def process_event({:click, :btn_update}, _, scene) do
    {:noreply, assign(scene, btn_text: "Updated")}
  end

  def process_event(_, _, scene) do
    {:noreply, scene}
  end
end
