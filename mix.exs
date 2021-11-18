defmodule FloUI.MixProject do
  use Mix.Project

  @version "0.1.0-alpha.3"
  @github "https://github.com/vacarsu/flo_ui"

  def project do
    [
      app: :flo_ui,
      name: "FloUI",
      version: @version,
      elixir: "~> 1.12",
      package: package(),
      description: description(),
      source_url: @github,
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:crypto, :logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:scenic, "~> 0.11.0-beta.0"},
      {:truetype_metrics, "~> 0.5"},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:snap_framework, "~> 0.1.0-alpha.3"}
    ]
  end

  defp description do
    """
    A library of Scenic components.
    """
  end

  defp package do
    [
      contributors: ["Alex Lopez"],
      maintainers: ["Alex Lopez"],
      licenses: ["MIT"],
      links: %{Github: @github},
      files: [
        # only include *.ex files
        "assets/icons/*.png",
        "lib/**/*.ex",
        "lib/**/*.eex",
        "mix.exs",
        "README.md",
        "LICENSE"
      ]
    ]
  end

  defp docs do
    [
      groups_for_modules: [
        FloUI: [
          FloUI,
          FloUI.Theme
        ],
        Icons: [
          FloUI.Icon.Button,
          FloUI.Icon.ButtonController,
          FloUI.Icon
        ],
        Dropdown: [
          FloUI.Dropdown,
          FloUI.Dropdown.Items,
          FloUI.Dropdown.Item,
          FloUI.DropdownController,
          FloUI.Dropdown.ItemController,
        ],
        Layout: [
          FloUI.Grid
        ],
        Modals: [
          FloUI.Modal.Background,
          FloUI.Modal.Body,
          FloUI.Modal.Header,
          FloUI.Modal.Layout
        ],
        Scrollable: [
          FloUI.Scrollable.Container,
          FloUI.Scrollable.ScrollBar,
          FloUI.Scrollable.Direction,
          FloUI.Scrollable.Drag,
          FloUI.Scrollable.Hotkeys,
          FloUI.Scrollable.PositionCap,
          FloUI.Scrollable.Wheel,
          FloUI.Scrollable.Acceleration,
          FloUI.Scrollable.ScrollBarController,
          FloUI.Scrollable.ScrollableContainerController
        ],
        SelectionList: [
          FloUI.SelectionList,
          FloUI.SelectionListItem,
          FloUI.SelectionListItemController
        ],
        Tabs: [
          FloUI.Tabs,
          FloUI.TabsController,
          FloUI.Tab,
          FloUI.TabController
        ],
        Input: [
          FloUI.Component.TextInput,
          FloUI.Component.TextInputController
        ],
        Tooltip: [
          FloUI.Tooltip
        ]
      ],
      source_ref: "v#{@version}",
      source_url: @github
    ]
  end
end
