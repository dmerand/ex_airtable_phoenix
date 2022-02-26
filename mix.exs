defmodule ExAirtable.Phoenix.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_airtable_phoenix,
      deps: deps(),
      description: description(),
      docs: docs(),
      elixir: "~> 1.11",
      package: package(),
      source_url: "https://github.com/dmerand/ex_airtable_phoenix",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_airtable, "~> 0.2.7"},
      {:ecto_sql, "~> 3.0"}
    ]
  end

  defp description do
    """
    Sane conventions for using ExAirtable with Ecto for schema validation.
    """
  end

  def docs do
    [
      extras: ["README.md"],
      main: "readme"
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/dmerand/ex_airtable_phoenix"}
    ]
  end
end
