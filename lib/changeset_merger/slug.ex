defmodule ChangesetMerger.Slug do
  @doc """
  Return a string in form of a slug for a given string.

  ## Examples

      iex> ChangesetMerger.Slug.generate(" Hi # there ")
      "hi-there"

      iex> ChangesetMerger.Slug.generate("Über den Wölkchen draußen im Tore")
      "ueber-den-woelkchen-draussen-im-tore"

      iex> ChangesetMerger.Slug.generate("_Trimming_and___Removing_inside___")
      "trimming-and-removing-inside"

  """
  def generate(text), do: text |> Slugger.slugify_downcase()

  @doc """
  Derive the slug from an existing field. If
  the source field is not set, then do not do anything.

  ## Examples

      iex> ChangesetMerger.create(%{"name" => "Granny Smith"}, %{name: :string})
      ...> |> ChangesetMerger.Slug.derive(:name)
      ...> |> Map.get(:changes)
      %{name: "Granny Smith", slug: "granny-smith"}

      iex> ChangesetMerger.create(%{"apples" => "Granny Smith"}, %{apples: :string})
      ...> |> ChangesetMerger.Slug.derive(:apples)
      ...> |> Map.get(:changes)
      %{apples: "Granny Smith", slug: "granny-smith"}

      iex> ChangesetMerger.create(%{}, %{apples: :string})
      ...> |> ChangesetMerger.Slug.derive(:apples, :apples_slug)
      ...> |> Map.get(:changes)
      %{}

      iex> ChangesetMerger.create(%{"apples" => "Granny Smith"}, %{apples: :string})
      ...> |> ChangesetMerger.Slug.derive(:apples, :apples_slug)
      ...> |> Map.get(:changes)
      %{apples: "Granny Smith", apples_slug: "granny-smith"}

      iex> ChangesetMerger.create(%{"apples" => "Granny Smith", "apples_slug" => "gsmith"}, %{apples: :string, apples_slug: :string})
      ...> |> ChangesetMerger.Slug.derive(:apples, :apples_slug)
      ...> |> Map.get(:changes)
      %{apples: "Granny Smith", apples_slug: "granny-smith"}

  """
  def derive(changeset), do: derive(changeset, :name, :slug)
  def derive(changeset, from_field), do: derive(changeset, from_field, :slug)

  def derive(changeset, from_field, to_field) do
    ChangesetMerger.derive(changeset, from_field, to_field, &ChangesetMerger.Slug.generate/1)
  end

  @doc """
  Derive the slug from an existing field. If
  the source field is not set, then do not do anything.

  Derive a field from another field based on the provided function.
  only if the target field IS NOT set.  If the source field
  is not set, then do not do anything.

  ## Examples

      iex> ChangesetMerger.create(%{"name" => "Granny Smith"}, %{name: :string})
      ...> |> ChangesetMerger.Slug.derive_if_missing(:name)
      ...> |> Map.get(:changes)
      %{name: "Granny Smith", slug: "granny-smith"}

      iex> ChangesetMerger.create(%{"apples" => "Granny Smith"}, %{apples: :string})
      ...> |> ChangesetMerger.Slug.derive_if_missing(:apples)
      ...> |> Map.get(:changes)
      %{apples: "Granny Smith", slug: "granny-smith"}

      iex> ChangesetMerger.create(%{}, %{apples: :string})
      ...> |> ChangesetMerger.Slug.derive_if_missing(:apples, :apples_slug)
      ...> |> Map.get(:changes)
      %{}

      iex> ChangesetMerger.create(%{"apples" => "Granny Smith"}, %{apples: :string})
      ...> |> ChangesetMerger.Slug.derive_if_missing(:apples, :apples_slug)
      ...> |> Map.get(:changes)
      %{apples: "Granny Smith", apples_slug: "granny-smith"}

      iex> ChangesetMerger.create(%{"apples" => "Granny Smith", "apples_slug" => "gsmith"}, %{apples: :string, apples_slug: :string})
      ...> |> ChangesetMerger.Slug.derive_if_missing(:apples, :apples_slug)
      ...> |> Map.get(:changes)
      %{apples: "Granny Smith", apples_slug: "gsmith"}

  """
  def derive_if_missing(changeset), do: derive_if_missing(changeset, :name, :slug)

  def derive_if_missing(changeset, from_field),
    do: derive_if_missing(changeset, from_field, :slug)

  def derive_if_missing(changeset, from_field, to_field) do
    ChangesetMerger.derive_if_missing(
      changeset,
      from_field,
      to_field,
      &ChangesetMerger.Slug.generate/1
    )
  end
end
