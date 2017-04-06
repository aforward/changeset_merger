defmodule ChangesetMerger do
  @moduledoc """
  A library to help you merge additional fields into your
  changeset params
  """

  @doc """
  Check for the `field` in the provided parameters, and if
  not found then set it ot the it based on the provide function.

  It will treat string and atoms as the same underlying value

  ## Examples

      iex> ChangesetMerger.defaulted(%{}, "apples", "blue")
      %{"apples" => "blue"}

      iex> ChangesetMerger.defaulted(%{}, :apples, "blue")
      %{apples: "blue"}

      iex> ChangesetMerger.defaulted(%{"apples" => "green"}, "apples", "blue")
      %{"apples" => "green"}

      iex> ChangesetMerger.defaulted(%{apples: "green"}, "apples", "blue")
      %{apples: "green"}

  """
  def defaulted(params, field, default_if_missing) when is_atom(field) do
    defaulted(params, field, "#{field}", field, default_if_missing)
  end
  def defaulted(params, field, default_if_missing) when is_binary(field) do
    defaulted(params, field, field, String.to_atom(field), default_if_missing)
  end
  defp defaulted(params, field, field_str, field_atom, default_if_missing) do
    cond do
      Map.has_key?(params, field_str) -> params
      Map.has_key?(params, field_atom) -> params
      :else -> Map.put(params, field, default_if_missing)
    end
  end
end
