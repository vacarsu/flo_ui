defmodule Basic.MixProject do
  use Mix.Project

  def project do
    [
      app: :basic,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Basic, []},
      extra_applications: [:crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scenic, "~> 0.11.0-beta.0"},
      {:scenic_driver_local, "~> 0.11.0-beta.0"},
      {:truetype_metrics, "~> 0.5"},
      {:dialyxir, "~> 1.1", only: :dev, runtime: false},
      {:flo_ui, path: Path.relative_to_cwd("../..")}
    ]
  end
end
