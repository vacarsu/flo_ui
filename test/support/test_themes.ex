defmodule FloUI.TestThemes do
  use Scenic.Themes, [
    [name: :scenic, themes: Scenic.Themes],
    [name: :flo_ui, themes: FloUI.Themes]
  ]
end
