defmodule FloUI.ModalHeaderTest do
  use FloUI.Test.TestCase,
    sync_children?: true,
    components: [
      {
        FloUI.Modal.Header,
        "test modal",
        [
          id: :test_modal,
          show_check: true,
          show_close: true,
          width: 500
        ]
      }
    ]

  doctest FloUI.Modal.Header

  @mouse_press_in_check {:cursor_button, {:btn_left, 1, [], {500 - 80, 5}}}
  @mouse_release_in_check {:cursor_button, {:btn_left, 0, [], {500 - 80, 5}}}
  @mouse_press_in_close {:cursor_button, {:btn_left, 1, [], {500 - 44, 5}}}
  @mouse_release_in_close {:cursor_button, {:btn_left, 0, [], {500 - 44, 5}}}

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

    assert_receive({:click, :btn_check}, 300)
  end

  test "event received when when close button clicked and released", %{vp: vp, comp_pid: comp_pid, child_pids: child_pids} do
    send_input(vp, comp_pid, child_pids, @mouse_press_in_close)
    send_input(vp, comp_pid, @mouse_release_in_close)

    assert_receive({:click, :btn_close}, 300)
  end
end
