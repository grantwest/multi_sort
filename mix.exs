defmodule MultiSort.MixProject do
  use Mix.Project

  @version "0.1.0"
  @description "Easily sort by multiple fields in a readable manner"
  @source_url "https://github.com/grantwest/multi_sort"

  def project do
    [
      app: :multi_sort,
      version: @version,
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: @description,
      aliases: aliases(),
      preferred_cli_env: [
        "test.watch": :test
      ],
      name: "MultiSort",
      docs: docs()
    ]
  end

  def application do
    []
  end

  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    []
  end

  defp package do
    %{
      licenses: ["0BSD"],
      maintainers: ["Grant West"],
      links: %{"GitHub" => @source_url}
    }
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md"],
      main: "readme"
    ]
  end
end
