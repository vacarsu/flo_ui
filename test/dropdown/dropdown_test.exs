defmodule FloUI.DropdownTest do
  use FloUI.Test.TestCase,
    sync_children?: true,
    components: [
      {
        FloUI.Dropdown,
        {[
          {{"option 1", :option_1}, :option_1},
          {{"option 2", :option_2}, :option_2}
        ], :option_1},
        [id: :test_dropdown, selected: false]
      }
    ]

  doctest FloUI.Dropdown

  alias Scenic.Graph
  alias Scenic.ViewPort.Input

  @options {[
    {{"option 1", :option_1}, :option_1},
    {{"option 2", :option_2}, :option_2}
  ], :option_1}

  @press_in {:cursor_button, {:btn_left, 1, [], {20, 20}}}
  @release_in {:cursor_button, {:btn_left, 0, [], {20, 20}}}

  @press_opt_1 {:cursor_button, {:btn_left, 1, [], {20, 65}}}
  @release_opt_1 {:cursor_button, {:btn_left, 0, [], {20, 65}}}

  @press_opt_2 {:cursor_button, {:btn_left, 1, [], {20, 100}}}
  @release_opt_2 {:cursor_button, {:btn_left, 0, [], {20, 100}}}

  @press_out {:cursor_button, {:btn_left, 1, [], {1000, 1000}}}
  @release_out {:cursor_button, {:btn_left, 0, [], {1000, 1000}}}

  test "validate accepts valid data" do
    assert FloUI.Dropdown.validate(@options) == {:ok, @options}
  end

  test "validate rejects invalid data" do
    {:error, msg} = FloUI.Dropdown.validate(123)
    assert msg =~ "Invalid Elixir.FloUI.Dropdown"
  end

  test "press in and release in opens the dropdown and press and release outside closes it", %{vp: vp, comp_pid: comp_pid, scene: scene} do
    send_input(vp, comp_pid, @press_in)
    send_input(vp, comp_pid, @release_in)

    scene
    |> get_child(:test_dropdown)
    |> get_primitive(:scroll_container)
    |> assert_styles(hidden: false)

    send_input(vp, comp_pid, @press_out)
    send_input(vp, comp_pid, @release_out)

    scene
    |> get_child(:test_dropdown)
    |> get_primitive(:scroll_container)
    |> assert_styles(hidden: true)
  end

  test "option 1 is selected by default", %{vp: vp, comp_pid: comp_pid, scene: scene} do
    scene
    |> get_child(:test_dropdown)
    |> assert_assigns(selected: :option_1)
  end

  test "can select option 2 from the dropdown and hides the dropdown", %{vp: vp, comp_pid: comp_pid, child_pids: child_pids} do
    send_input(vp, comp_pid, child_pids, @press_in)
    send_input(vp, comp_pid, child_pids, @release_in)
    send_input(vp, comp_pid, child_pids, @press_opt_2)
    send_input(vp, comp_pid, child_pids, @release_opt_2)

    assert_receive({:value_changed, :test_dropdown, :option_2}, 500)
  end
end
