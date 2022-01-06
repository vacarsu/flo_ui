defmodule FloUI.IconButtonTest do
  use FloUI.Test.TestCase,
    components: [
      {
        FloUI.Icon.Button,
        "test",
        [
          id: :test_btn,
          children: [type: :component, module: FloUI.Icon, data: {:flo_ui, "icons/clear_white.png"}, opts: []]
        ]
      }
    ]

  doctest FloUI.Icon.Button

  alias Scenic.Graph
  alias Scenic.ViewPort.Input

  @mouse_over {:cursor_pos, {20, 20}}
  @mouse_out {:cursor_pos, {1000, 1000}}

  @press_in {:cursor_button, {:btn_left, 1, [], {20, 20}}}
  @release_in {:cursor_button, {:btn_left, 0, [], {20, 20}}}

  @press_out {:cursor_button, {:btn_left, 1, [], {1000, 1000}}}
  @release_out {:cursor_button, {:btn_left, 0, [], {1000, 1000}}}

  test "validate passes valid data" do
    assert FloUI.Icon.Button.validate("test") == {:ok, "test"}
  end

  test "validate rejects initial value outside the extents" do
    {:error, msg} = FloUI.Icon.Button.validate(123)
    assert msg =~ "Invalid Elixir.FloUI.Icon.Button"
  end

  test "Press in and release in sends the event", %{vp: vp, comp_pid: comp_pid} do
    send_input(vp, comp_pid, @press_in)
    send_input(vp, @release_in)
    assert_receive({:click, :test_btn})
  end

  test "Press in and release out does not send the event", %{vp: vp, comp_pid: comp_pid} do
    send_input(vp, comp_pid, @press_in)
    send_input(vp, @release_out)
    refute_receive(_, 10)
  end

  test "Mouse over reveals the tooltip and mouse out hides it", %{vp: vp, comp_pid: comp_pid, scene: scene} do
    send_input(vp, comp_pid, @mouse_over)
    scene
    |> get_child(:test_btn)
    |> get_primitive(:tooltip)
    |> assert_styles(hidden: false)

    send_input(vp, comp_pid, @mouse_out)
    scene
    |> get_child(:test_btn)
    |> get_primitive(:tooltip)
    |> assert_styles(hidden: true)
  end
end
