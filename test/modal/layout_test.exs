defmodule FloUI.ModalLayoutTest do
  use FloUI.Test.TestCase,
    sync_children?: true,
    components: [
      {
        FloUI.Modal.Layout,
        "test modal",
        [
          id: :test_modal,
          show_check: true,
          show_close: true,
          width: 500,
          height: 500,
          children: [
            [type: :primitive, module: Scenic.Primitive.Text, data: "test", opts: []]
          ]
        ]
      }
    ]

  doctest FloUI.Modal.Layout

  @mouse_press_in_check {:cursor_button, {:btn_left, 1, [], {500 - 80, 5}}}
  @mouse_release_in_check {:cursor_button, {:btn_left, 0, [], {500 - 80, 5}}}
  @mouse_press_in_close {:cursor_button, {:btn_left, 1, [], {500 - 30, 5}}}
  @mouse_release_in_close {:cursor_button, {:btn_left, 0, [], {500 - 30, 5}}}

  test "validate passes valid data" do
    assert FloUI.Modal.Layout.validate("test modal") == {:ok, "test modal"}
  end

  test "validate rejects initial value outside the extents" do
    {:error, msg} = FloUI.Modal.Layout.validate(123)
    assert msg =~ "Invalid Elixir.FloUI.Modal.Layout"
  end

  test "event received when when check button clicked and released", %{vp: vp, comp_pid: comp_pid, child_pids: child_pids} do
    send_input(vp, comp_pid, child_pids, @mouse_press_in_check)
    send_input(vp, comp_pid, @mouse_release_in_check)

    assert_receive(:modal_done, 100)
  end

  test "event received when when close button clicked and released", %{vp: vp, comp_pid: comp_pid, child_pids: child_pids} do
    send_input(vp, comp_pid, child_pids, @mouse_press_in_close)
    send_input(vp, comp_pid, @mouse_release_in_close)

    assert_receive(:modal_close, 100)
  end
end
