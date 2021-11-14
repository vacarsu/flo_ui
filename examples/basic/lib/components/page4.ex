defmodule Basic.Component.Page4 do
  use SnapFramework.Component,
    name: :page_4,
    template: "lib/components/page_4.eex",
    controller: :none,
    assigns: [
      dropdown_opts: {
        [
          {{"Select Item", :select}, :select},
          {{"Item 1", "Item 1"}, :item_1},
          {{"Item 2", "Item 2"}, :item_2},
          {{"Item 3", "Item 3"}, :item_3},
          {{"Item 4", "Item 4"}, :item_4},
          {{"Item 5", "Item 5"}, :item_5},
          {{"Item 6", "Item 6"}, :item_6},
          {{"Item 7", "Item 7"}, :item_7}
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
      }
    ],
    opts: []

  defcomponent(:page_4, :any)
end
