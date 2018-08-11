defmodule ChangesetMerger.Mixfile do
  use Mix.Project

  @git_url "https://github.com/aforward/changeset_merger"
  @home_url @git_url
  @version "0.3.17"

  def project do
    [
      app: :changeset_merger,
      version: @version,
      elixir: ">= 1.4.0",
      name: "ChangesetMerger",
      description: "A library for common Ecto changeset transformations.",
      package: package(),
      source_url: @git_url,
      homepage_url: @home_url,
      docs: [main: "ChangesetMerger", extras: ["README.md"]],
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
      {:ex_doc, github: "elixir-lang/ex_doc", only: :dev},
      {:ecto, "~> 2.2"},
      {:slugger, "~> 0.2.0"},
      {:version_tasks, "~> 0.10"},
      {:fn_expr, "~> 0.2"},
      {:timex, "~> 3.1"}
    ]
  end

  defp package do
    [
      name: :changeset_merger,
      files: ["lib", "mix.exs", "README*", "README*", "LICENSE*"],
      maintainers: ["Andrew Forward"],
      licenses: ["MIT"],
      links: %{"GitHub" => @git_url}
    ]
  end
end
