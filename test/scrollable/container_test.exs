defmodule FloUI.ScrollableContainerTest do
  use FloUI.Test.TestCase,
    sync_children?: true,
    components: [
      {
        FloUI.Scrollable.Container,
        %{
          frame: {400, 500},
          content: {800, 800},
          scroll_position: {0, 0}
        },
        [
          id: :scrollable,
          translate: {0, 0},
          scroll_bars: %{
              vertical: %{
                  show: true,
                  show_buttons: true,
                  thickness: 15
              },
              horizontal: %{
                  show: true,
                  show_buttons: true,
                  thickness: 15
              }
          },
          children: [
            [type: :component, module: FloUI.Icon.Button, data: "test", opts: []]
          ]
        ]
      }
    ]

  doctest FloUI.Scrollable.Container

  @container_data %{
    frame: {400, 500},
    content: {800, 800},
    scroll_position: {0, 0}
  }

  # vertical inputs
  @press_vertical_down_button {:cursor_button, {:btn_left, 1, [], {412, 498}}}
  @release_vertical_down_button {:cursor_button, {:btn_left, 0, [], {412, 498}}}

  @press_vertical_bg {:cursor_button, {:btn_left, 1, [], {407.01171875, 469.3515625}}}
  @release_vertical_bg {:cursor_button, {:btn_left, 0, [], {407.01171875, 469.3515625}}}

  @press_vertical_scroll_bar {:cursor_button, {:btn_left, 1, [], {412, 500}}}
  @drag_vertical_scroll_bar {:cursor_pos, {412, 530}}
  @release_vertical_scroll_bar {:cursor_button, {:btn_left, 1, [], {412, 530}}}

  @cursor_scroll_vertical_in {:cursor_scroll, {{0, -10}, {50, 50}}}
  @cursor_scroll_vertical_out {:cursor_scroll, {{0, -10}, {1000, 1000}}}

  # horizontal inputs
  @press_horizontal_right_button {:cursor_button, {:btn_left, 1, [], {398, 512}}}
  @release_horizontal_right_button {:cursor_button, {:btn_left, 0, [], {398, 512}}}

  @press_horizontal_bg {:cursor_button, {:btn_left, 1, [], {378.3359375, 508.7734375}}}
  @release_horizontal_bg {:cursor_button, {:btn_left, 0, [], {378.3359375, 508.7734375}}}

  @press_horizontal_scroll_bar {:cursor_button, {:btn_left, 1, [], {20, 512}}}
  @drag_horizontal_scroll_bar {:cursor_pos, {100, 512}}
  @release_horizontal_scroll_bar {:cursor_button, {:btn_left, 1, [], {100, 512}}}

  @cursor_scroll_horizontal_in {:cursor_scroll, {{10, 0}, {50, 50}}}
  @cursor_scroll_horizontal_out {:cursor_scroll, {{10, 0}, {1000, 1000}}}

  test "validate passes valid data" do
    assert FloUI.Scrollable.Container.validate(@container_data) == {:ok, @container_data}
  end

  test "validate rejects initial value outside the extents" do
    {:error, msg} = FloUI.Scrollable.Container.validate(123)
    assert msg =~ "Invalid Elixir.FloUI.Scrollable.Container"
  end

  test "pressing vertical scroll button send scroll_position_changed", %{vp: vp, comp_pid: comp_pid, child_pids: child_pids, scene: scene} do
    send_input(vp, comp_pid, child_pids, @press_vertical_down_button)
    send_input(vp, comp_pid, @release_vertical_down_button)

    assert_receive({:scroll_position_changed, {-0.0, 1.8}}, 100)
  end

  test "pressing horizontal scroll button send scroll_position_changed", %{vp: vp, comp_pid: comp_pid, child_pids: child_pids, scene: scene} do
    send_input(vp, comp_pid, child_pids, @press_horizontal_right_button)
    send_input(vp, comp_pid, @release_horizontal_right_button)

    assert_receive({:scroll_position_changed, {1.8, -0.0}}, 200)
  end

  test "pressing vertical background jumps to position", %{vp: vp, comp_pid: comp_pid, child_pids: child_pids, scene: scene} do
    send_input(vp, comp_pid, child_pids, @press_vertical_bg)
    send_input(vp, comp_pid, @release_vertical_bg)

    assert_receive({:scroll_position_changed, {0, 300.0}}, 200)
  end

  test "pressing horizontal background jumps to position", %{vp: vp, comp_pid: comp_pid, child_pids: child_pids, scene: scene} do
    send_input(vp, comp_pid, child_pids, @press_horizontal_bg)
    send_input(vp, comp_pid, @release_horizontal_bg)

    assert_receive({:scroll_position_changed, {400.0, 0}}, 200)
  end

  test "dragging the vertical scroll bar moves the position", %{vp: vp, comp_pid: comp_pid, child_pids: child_pids, scene: scene} do
    send_input(vp, comp_pid, child_pids, @press_vertical_scroll_bar)
    send_input(vp, comp_pid, child_pids, @drag_vertical_scroll_bar)
    send_input(vp, comp_pid, @release_vertical_scroll_bar)

    assert_receive({:scroll_position_changed, {-0.0, 1.8}}, 200)
  end

  test "dragging the horizontal scroll bar moves the position", %{vp: vp, comp_pid: comp_pid, child_pids: child_pids, scene: scene} do
    send_input(vp, comp_pid, child_pids, @press_horizontal_scroll_bar)
    send_input(vp, comp_pid, child_pids, @drag_horizontal_scroll_bar)
    send_input(vp, comp_pid, @release_horizontal_scroll_bar)

    assert_receive({:scroll_position_changed, {172.97297297297297, 0}}, 200)
  end
end
