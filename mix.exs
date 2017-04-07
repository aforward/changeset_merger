defmodule ChangesetMerger.Mixfile do
  use Mix.Project

  @git_url "https://github.com/aforward/changeset_merger"
  @home_url @git_url
  @version "0.3.1"

  def project do
    [app: :changeset_merger,
     version: @version,
     elixir: "~> 1.4",
     name: "ChangesetMerger",
     description: "A library for common Ecto changeset transformations.",
     package: package(),
     source_url: @git_url,
     homepage_url: @home_url,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:ecto, "~> 2.1"},
     {:slugger, "~> 0.1.0"}]
  end

  defp package do
    [name: :changeset_merger,
     files: ["lib", "mix.exs", "README*", "README*", "LICENSE*"],
     maintainers: ["Andrew Forward"],
     licenses: ["MIT"],
     links: %{"GitHub" => @git_url}]
  end
end
