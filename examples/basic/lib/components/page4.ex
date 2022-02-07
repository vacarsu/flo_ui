defmodule Basic.Component.Page4 do
  use SnapFramework.Component,
    name: :page_4,
    template: "lib/components/page_4.eex",
    controller: :none,
    assigns: [
      dropdown_opts: {
        [
          {{"item", :select}, :select},
          {{"Item 1 fefuewhfluihjdfhdjd", "Item 1"}, :item_1},
          {{"Item 2", "Item 2"}, :item_2},
          {{"Item 3", "Item 3"}, :item_3}
        ],
        :select
      },
      selection_list: {
        [
          {"number 1", "number 1", 0},
          {"number 2", "number 2", 1},
          {"number 3", "number 3", 2}
        ],
        0
      },
      selected_dropdown_item: :select,
      selected_list_item: 0,
    ],
    opts: []

  def process_event({:value_changed, :scroll_dropdown, value}, _, scene) do
    {:noreply, assign(scene, selected_dropdown_item: value)}
  end

  def process_event({:value_changed, :selection_list, nil}, _, scene) do
    {:noreply, assign(scene, selected_list_item: :select)}
  end

  def process_event({:value_changed, :selection_list, {_, value, _}}, _, scene) do
    {:noreply, assign(scene, selected_list_item: value)}
  end

  def process_event(_, _, scene) do
    {:noreply, scene}
  end
end
