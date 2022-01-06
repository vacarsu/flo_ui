defmodule FloUI.TooltipTest do
  use FloUI.Test.TestCase,
    components: [
      {FloUI.Tooltip, "test tooltip", [id: :test_tooltip]}
    ]

  doctest FloUI.Tooltip

  test "validate passes valid data" do
    assert FloUI.Tooltip.validate("test tooltip") == {:ok, "test tooltip"}
  end

  test "validate rejects initial value outside the extents" do
    {:error, msg} = FloUI.Tooltip.validate(123)
    assert msg =~ "Invalid Elixir.FloUI.Tooltip"
  end

  test "tooltip background is the surface color", %{scene: scene} do
    scene
    |> get_child(:test_tooltip)
    |> get_primitive(:bg)
    |> assert_styles(fill: {:color, {:color_rgba, {82, 82, 82, 255}}})
  end

  test "tooltip displays the correct text", %{scene: scene} do
    scene
    |> get_child(:test_tooltip)
    |> get_primitive(:txt_tooltip)
    |> assert_data("test tooltip")
  end
end
