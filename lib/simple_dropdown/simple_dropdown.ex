defmodule FloUI.SimpleDropdown do
  alias FloUI.Util.FontMetricsHelper

  use SnapFramework.Component,
    name: :simple_dropdown,
    type: :custom,
    template: "lib/simple_dropdown/simple_dropdown.eex",
    controller: FloUI.SimpleDropdownController,
    assigns: [
      label: nil,
      cmp: nil,
      id: nil,
      disabled?: false,
      selected?: false,
      hovered?: false
    ]

  def validate({dropdown_opts, _selected} = data) when is_list(dropdown_opts), do: {:ok, data}

  def validate(data) do
    {
      :error,
      """
      #{IO.ANSI.red()}Invalid #{__MODULE__} specification
      Received: #{inspect(data)}
      #{IO.ANSI.yellow()}
      The data for  #{__MODULE__} must be a tuple with a list and a selected value, {opts, selected}.#{IO.ANSI.default_color()}
      """
    }
  end

  def setup(%{assigns: %{data: {opts, selected}}} = scene) do
    assign(scene, opts: opts, selected: selected)
  end
end
