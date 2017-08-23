defmodule ChangesetMerger.Config do
  use FnExpr

  @doc"""
  Provide a basic implemetation of a callback `init` when a configuration is read.

  The input is the provided configuration as stored in the application environment.
  The return value will be {:ok, config} with the updated list of configuration
  based on extracting any ${<some_name>} environment variables.

  This is useful, for example, when configuring your [Ecto Repo](https://hexdocs.pm/ecto/Ecto.Repo.html#c:init/2)
  for configuration values loaded at runtime.

  """
  def init(config) do
    config
    |> resolve
    |> invoke({:ok, &1})
  end

  @doc"""
  Resolve the provided input.  If the input is of the form
  ${<some_name>}, then lookup the environment variable
  "<some_name>".  If the value is nil, then raise an exception
  as your system appears to not be configured as expected.

  ### Examples

  For regular inputs, just pass through the information

        iex> ChangesetMerger.Config.resolve(1)
        1

        iex> ChangesetMerger.Config.resolve(:a)
        :a

        iex> ChangesetMerger.Config.resolve("b")
        "b"

        iex> ChangesetMerger.Config.resolve(["c", "d", "e"])
        ["c", "d", "e"]

        iex> ChangesetMerger.Config.resolve(%{c: "c", d: "d"})
        %{c: "c", d: "d"}

  """
  def resolve(input) when is_list(input) do
    input |> Enum.map(fn v -> resolve(v) end)
  end

  def resolve({k, v}) do
    {k, v |> resolve}
  end

  def resolve(input) when is_map(input) do
    input
    |> Enum.map(fn {k, v} -> {k, resolve(v)} end)
    |> Enum.into(%{})
  end

  def resolve(input) when is_binary(input) do
    Regex.scan(~r/\${([^}]+)}/, input)
    |> Enum.map(fn [_, env] ->
         {env, System.get_env(env)}
       end)
    |> Enum.into(%{})
    |> track_missing
    |> Enum.reduce(input, fn {env, val}, new_input ->
         String.replace(new_input, "${#{env}}", val)
       end)
  end

  def resolve(input), do: input


  def track_missing(envs) do
    envs
    |> Enum.filter(fn {_k, v} -> is_nil(v) end)
    |> invoke(fn
         [] -> envs
         errs -> raise "Missing env variable(s) #{errs |> Enum.into(%{}) |> Map.keys |> Enum.join(", ")}"
       end)
  end


end