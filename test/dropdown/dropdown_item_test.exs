defmodule FloUI.DropdownItemTest do
  use FloUI.Test.TestCase,
    components: [
      {
        FloUI.Dropdown.Item,
        {{"option 1", :option_1}, :option_1},
        [id: :test_dropdown_item, selected: false, width: 300]
      }
    ]

  doctest FloUI.Dropdown

  alias Scenic.ViewPort.Input

  @press_in {:cursor_button, {:btn_left, 1, [], {20, 20}}}
  @release_in {:cursor_button, {:btn_left, 0, [], {20, 20}}}

  @press_out {:cursor_button, {:btn_left, 1, [], {1000, 1000}}}
  @release_out {:cursor_button, {:btn_left, 0, [], {1000, 1000}}}

  test "validate accepts valid data" do
    assert FloUI.Dropdown.Item.validate({{"option 1", :option_1}, :option_1}) == {:ok, {{"option 1", :option_1}, :option_1}}
  end

  test "validate rejects invalid data" do
    {:error, msg} = FloUI.Dropdown.Item.validate(123)
    assert msg =~ "Invalid Elixir.FloUI.Dropdown.Item"
  end

  test "can be selected on click", %{vp: vp, comp_pid: comp_pid, scene: scene} do
    send_input(vp, comp_pid, @press_in)
    send_input(vp, @release_in)
    assert_receive({:click, :test_dropdown_item, {{"option 1", :option_1}, :option_1}}, 100)
  end
end
