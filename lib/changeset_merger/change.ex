defmodule ChangesetMerger.Change do
  @moduledoc """
  The ability to manipulate a changeset
  after it has been cast from the provided parameters
  """

  @doc """
  Check for the `field` in the provided changeset, and if
  not found then set it ot the it based on the provide function.

  ## Examples

      iex> ChangesetMerger.Change.create(%{}, %{apples: :string})
      ...> |> ChangesetMerger.Change.defaulted(:apples, "blue")
      ...> |> Map.get(:changes)
      %{apples: "blue"}

      iex> ChangesetMerger.Change.create(%{"apples" => "red"}, %{apples: :string})
      ...> |> ChangesetMerger.Change.defaulted(:apples, "blue")
      ...> |> Map.get(:changes)
      %{apples: "red"}
  """
  def defaulted(changeset, field, default_if_missing) do
    case Ecto.Changeset.get_change(changeset, field) do
      nil -> Ecto.Changeset.put_change(changeset, field, default_if_missing)
      _ -> changeset
    end
  end

  @doc """
  Force a field to be a certain value.

  ## Examples

      iex> ChangesetMerger.Change.create(%{}, %{apples: :string})
      ...> |> ChangesetMerger.Change.force(:apples, "blue")
      ...> |> Map.get(:changes)
      %{apples: "blue"}

      iex> ChangesetMerger.Change.create(%{"apples" => "green"}, %{apples: :string})
      ...> |> ChangesetMerger.Change.force(:apples, "blue")
      ...> |> Map.get(:changes)
      %{apples: "blue"}

  """
  def force(changeset, field, val) do
    Ecto.Changeset.put_change(changeset, field, val)
  end

  @doc """
  Derive a field from another field based on the provided function.  If
  the source field is not set, then do not do anything.

  ## Examples

      iex> ChangesetMerger.Change.create(%{}, %{apples: :string})
      ...> |> ChangesetMerger.Change.derive(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{}

      iex> ChangesetMerger.Change.create(%{"apples" => "green"}, %{apples: :string})
      ...> |> ChangesetMerger.Change.derive(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{apples: "green", oranges: "neerg"}

      iex> ChangesetMerger.Change.create(%{"apples" => "green", "oranges" => "blue"}, %{apples: :string, oranges: :string})
      ...> |> ChangesetMerger.Change.derive(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{apples: "green", oranges: "neerg"}

  """
  def derive(changeset, from_field, to_field, fun) do
    case Ecto.Changeset.get_change(changeset, from_field) do
      nil -> changeset
      val -> Ecto.Changeset.put_change(changeset, to_field, fun.(val))
    end
  end

  @doc """
  Derive a field from another field based on the provided function.
  only if the target field IS NOT set.  If the source field
  is not set, then do not do anything.

  ## Examples

      iex> ChangesetMerger.Change.create(%{}, %{apples: :string})
      ...> |> ChangesetMerger.Change.derive_if_missing(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{}

      iex> ChangesetMerger.Change.create(%{"apples" => "green"}, %{apples: :string})
      ...> |> ChangesetMerger.Change.derive_if_missing(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{apples: "green", oranges: "neerg"}

      iex> ChangesetMerger.Change.create(%{"apples" => "green", "oranges" => "blue"}, %{apples: :string, oranges: :string})
      ...> |> ChangesetMerger.Change.derive_if_missing(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{apples: "green", oranges: "blue"}

  """
  def derive_if_missing(changeset, from_field, to_field, fun) do
    case Ecto.Changeset.get_change(changeset, from_field) do
      nil -> changeset
      val -> defaulted(changeset, to_field, fun.(val))
    end
  end

  def create(params, types) do
    {%{}, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
  end

end
