defmodule FloUI.IconTest do
  use FloUI.Test.TestCase,
    components: [
      {FloUI.Icon, {:flo_ui, "icons/clear_white.png"}, [id: :test_icon]}
    ]

  doctest FloUI.Icon

  test "validate passes valid data" do
    assert FloUI.Icon.validate({:flo_ui, "icons/clear_white.png"}) == {:ok, {:flo_ui, "icons/clear_white.png"}}
  end

  test "validate rejects initial value outside the extents" do
    {:error, msg} = FloUI.Icon.validate(123)
    assert msg =~ "Invalid Elixir.FloUI.Icon"
  end

  test "image is rendered", %{scene: scene} do
    scene
    |> get_child(:test_icon)
    |> get_primitive(:icon_rect)
    |> assert_styles(fill: {:image, {:flo_ui, "icons/clear_white.png"}})
    # [icon_scene | _] = Scenic.Scene.get_child(scene, :test_icon)
    # [icon | _] = Graph.get(icon_scene.assigns.graph, :icon_rect)
    # assert icon.styles.fill ==  {:image, {:flo_ui, "icons/clear_white.png"}}
  end
end
