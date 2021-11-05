defmodule Basic.Component.Page4 do
  use SnapFramework.Component,
    name: :page_4,
    template: "lib/components/page_4.eex",
    controller: :none,
    assigns: [
      dropdown_opts: {
        [
            {%{label: "Select Item", value: nil}, :select},
            {%{label: "Item 1", value: "Item 1"}, :item_1},
            {%{label: "Item 2", value: "Item 2"}, :item_2},
            {%{label: "Item 3", value: "Item 3"}, :item_3},
            {%{label: "Item 4", value: "Item 4"}, :item_4},
            {%{label: "Item 5", value: "Item 5"}, :item_5},
            {%{label: "Item 6", value: "Item 6"}, :item_6},
            {%{label: "Item 7", value: "Item 7"}, :item_7},
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

  defcomponent :page_4, :any
end
