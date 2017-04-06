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

  @doc """
  Force a field to be a certain value.

  It will treat string and atoms as the same underlying value

  ## Examples

      iex> ChangesetMerger.force(%{}, "apples", "blue")
      %{"apples" => "blue"}

      iex> ChangesetMerger.force(%{}, :apples, "blue")
      %{apples: "blue"}

      iex> ChangesetMerger.force(%{"apples" => "green"}, "apples", "blue")
      %{"apples" => "blue"}

      iex> ChangesetMerger.force(%{apples: "green"}, "apples", "blue")
      %{apples: "blue"}

  """
  def force(params, field, val) when is_atom(field) do
    force(params, field, "#{field}", field, val)
  end
  def force(params, field, val) when is_binary(field) do
    force(params, field, field, String.to_atom(field), val)
  end
  defp force(params, field, field_str, field_atom, val) do
    cond do
      Map.has_key?(params, field_str) -> Map.put(params, field_str, val)
      Map.has_key?(params, field_atom) -> Map.put(params, field_atom, val)
      :else -> Map.put(params, field, val)
    end
  end

  @doc """
  Derive a field from another field based on the provided function.  If
  the source field is not set, then do not do anything.

  It will treat string and atoms as the same underlying value

  ## Examples

      iex> ChangesetMerger.derive(%{}, "apples", "oranges", fn(x) -> String.reverse(x) end)
      %{}

      iex> ChangesetMerger.derive(%{"apples" => "green"}, "apples", "oranges", fn(x) -> String.reverse(x) end)
      %{"apples" => "green", "oranges" => "neerg"}

      iex> ChangesetMerger.derive(%{"apples" => "green", "oranges" => "ignore"}, "apples", "oranges", fn(x) -> String.reverse(x) end)
      %{"apples" => "green", "oranges" => "neerg"}

      iex> ChangesetMerger.derive(%{apples: "green"}, "apples", "oranges", fn(x) -> String.reverse(x) end)
      %{:apples => "green", "oranges" => "neerg"}

  """
  def derive(params, from_field, to_field, fun) when is_atom(from_field) do
    derive(params, "#{from_field}", from_field, to_field, fun)
  end
  def derive(params, from_field, to_field, fun) when is_binary(from_field) do
    derive(params, from_field, String.to_atom(from_field), to_field, fun)
  end
  defp derive(params, field_str, field_atom, to_field, fun) do
    cond do
      Map.has_key?(params, field_str) -> Map.put(params, to_field, fun.(params[field_str]))
      Map.has_key?(params, field_atom) -> Map.put(params, to_field, fun.(params[field_atom]))
      :else -> params
    end
  end

  @doc """
  Derive a field from another field based on the provided function.
  only if the target field IS NOT set.  If the source field
  is not set, then do not do anything.

  It will treat string and atoms as the same underlying value

  ## Examples

      iex> ChangesetMerger.derive_if_missing(%{}, "apples", "oranges", fn(x) -> String.reverse(x) end)
      %{}

      iex> ChangesetMerger.derive_if_missing(%{"apples" => "green"}, "apples", "oranges", fn(x) -> String.reverse(x) end)
      %{"apples" => "green", "oranges" => "neerg"}

      iex> ChangesetMerger.derive_if_missing(%{apples: "green"}, "apples", "oranges", fn(x) -> String.reverse(x) end)
      %{:apples => "green", "oranges" => "neerg"}

      iex> ChangesetMerger.derive_if_missing(%{"apples" => "green", "oranges" => "overwritten"}, "apples", "oranges", fn(x) -> String.reverse(x) end)
      %{"apples" => "green", "oranges" => "overwritten"}

  """
  def derive_if_missing(params, from_field, to_field, fun) when is_atom(from_field) do
    derive_if_missing(params, "#{from_field}", from_field, to_field, fun)
  end
  def derive_if_missing(params, from_field, to_field, fun) when is_binary(from_field) do
    derive_if_missing(params, from_field, String.to_atom(from_field), to_field, fun)
  end
  defp derive_if_missing(params, field_str, field_atom, to_field, fun) do
    cond do
      Map.has_key?(params, field_str) -> defaulted(params, to_field, fun.(params[field_str]))
      Map.has_key?(params, field_atom) -> defaulted(params, to_field, fun.(params[field_atom]))
      :else -> params
    end
  end
end
