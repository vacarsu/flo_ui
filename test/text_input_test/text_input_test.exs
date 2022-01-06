defmodule FloUI.TextInputTest do
  use FloUI.Test.TestCase,
    sync_children?: true,
    components: [
      {FloUI.TextInput, "test", [id: :test_input, width: 100, show_clear: true]}
    ]

  doctest FloUI.TextInput

  alias Scenic.ViewPort.Input

  @clear_press_in {:cursor_button, {:btn_left, 1, [], {100 - 40, 10}}}
  @clear_release_in {:cursor_button, {:btn_left, 0, [], {100 - 40, 10}}}

  test "validate passes valid data" do
    assert FloUI.TextInput.validate("test tooltip") == {:ok, "test tooltip"}
  end

  test "validate rejects initial value outside the extents" do
    {:error, msg} = FloUI.TextInput.validate(123)
    assert msg =~ "Invalid Elixir.FloUI.TextInput"
  end

  test "pressing and releasing clear btn clears the text input", %{vp: vp, comp_pid: comp_pid, child_pids: child_pids, scene: scene} do
    send_input(vp, comp_pid, child_pids, @clear_press_in)
    send_input(vp, comp_pid, child_pids, @clear_release_in)

    scene
    |> get_child(:test_input)
    |> assert_assigns(data: "")

    assert_receive({:value_changed, :test_input, ""}, 1000)
  end
end
