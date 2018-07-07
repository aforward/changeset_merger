defmodule ChangesetMerger do
  @moduledoc """
  A library to help you manipulate changes in your changeset
  with relative ease
  """

  import Ecto.Changeset, only: [put_change: 3, get_field: 2]

  @doc """
  Check for the `field` in the provided changeset, and if
  not found then set it ot the it based on the provide function.

  ## Examples

      iex> ChangesetMerger.create(%{}, %{apples: :string})
      ...> |> ChangesetMerger.defaulted(:apples, "blue")
      ...> |> Map.get(:changes)
      %{apples: "blue"}

      iex> ChangesetMerger.create(%{apples: "red"}, %{}, %{apples: :string})
      ...> |> ChangesetMerger.defaulted(:apples, "blue")
      ...> |> Map.get(:changes)
      %{}

      iex> ChangesetMerger.create(%{"apples" => "red"}, %{apples: :string})
      ...> |> ChangesetMerger.defaulted(:apples, "blue")
      ...> |> Map.get(:changes)
      %{apples: "red"}
  """
  def defaulted(changeset, field, default_if_missing) do
    case get_field(changeset, field) do
      nil -> put_change_if(changeset, field, default_if_missing)
      _ -> changeset
    end
  end

  @doc """
  Force a field to be a certain value.

  ## Examples

      iex> ChangesetMerger.create(%{}, %{apples: :string})
      ...> |> ChangesetMerger.force(:apples, "blue")
      ...> |> Map.get(:changes)
      %{apples: "blue"}


      iex> ChangesetMerger.create(%{"apples" => "green"}, %{apples: :string})
      ...> |> ChangesetMerger.force(:apples, "blue")
      ...> |> Map.get(:changes)
      %{apples: "blue"}

  """
  def force(changeset, field, val) do
    put_change_if(changeset, field, val)
  end

  @doc """
  Derive a field from another field (or fields) based on the provided function.  If
  the source field is not set, then do not do anything.

  ## Examples

      iex> ChangesetMerger.create(%{}, %{apples: :string})
      ...> |> ChangesetMerger.derive(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{}

      iex> ChangesetMerger.create(%{"apples" => "green"}, %{apples: :string})
      ...> |> ChangesetMerger.derive(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{apples: "green", oranges: "neerg"}

      iex> ChangesetMerger.create(%{apples: "green"}, %{}, %{apples: :string})
      ...> |> ChangesetMerger.derive(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{oranges: "neerg"}

      iex> ChangesetMerger.create(%{apples: "green", oranges: "neerg"}, %{}, %{apples: :string})
      ...> |> ChangesetMerger.derive(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{}

      iex> ChangesetMerger.create(%{"apples" => "green", "bananas" => "blue"}, %{apples: :string, bananas: :string})
      ...> |> ChangesetMerger.derive([:apples, :bananas], :oranges, fn([a,b]) -> a <> b end)
      ...> |> Map.get(:changes)
      %{apples: "green", bananas: "blue", oranges: "greenblue"}

      iex> ChangesetMerger.create(%{"apples" => "green"}, %{apples: :string})
      ...> |> ChangesetMerger.derive(:apples, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{apples: "neerg"}

      iex> ChangesetMerger.create(%{"apples" => "green", "oranges" => "blue"}, %{apples: :string, oranges: :string})
      ...> |> ChangesetMerger.derive(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{apples: "green", oranges: "neerg"}

  """
  def derive(changeset, field, fun), do: derive(changeset, field, field, fun)

  def derive(changeset, from_field_or_fields, to_field, fun) do
    case field_values(changeset, from_field_or_fields) do
      nil -> changeset
      inputs -> put_change_if(changeset, to_field, fun.(inputs))
    end
  end

  @doc """
  Derive a field from another field (or fields) based on the provided function.
  only if the target field IS NOT set.  If the source field
  is not set, then do not do anything.

  ## Examples

      iex> ChangesetMerger.create(%{}, %{apples: :string})
      ...> |> ChangesetMerger.derive_if_missing(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{}

      iex> ChangesetMerger.create(%{"apples" => "green", "bananas" => "blue"}, %{apples: :string, bananas: :string})
      ...> |> ChangesetMerger.derive_if_missing([:apples, :bananas], :oranges, fn([a,b]) -> a <> b end)
      ...> |> Map.get(:changes)
      %{apples: "green", bananas: "blue", oranges: "greenblue"}

      iex> ChangesetMerger.create(%{"apples" => "green"}, %{apples: :string})
      ...> |> ChangesetMerger.derive_if_missing(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{apples: "green", oranges: "neerg"}

      iex> ChangesetMerger.create(%{"apples" => "green", "oranges" => "blue"}, %{apples: :string, oranges: :string})
      ...> |> ChangesetMerger.derive_if_missing(:apples, :oranges, fn(x) -> String.reverse(x) end)
      ...> |> Map.get(:changes)
      %{apples: "green", oranges: "blue"}

      iex> ChangesetMerger.create(%{"apples" => "green", "bananas" => "blue", "oranges" => "purple"}, %{apples: :string, bananas: :string, oranges: :string})
      ...> |> ChangesetMerger.derive_if_missing([:apples, :bananas], :oranges, fn([a,b]) -> a <> b end)
      ...> |> Map.get(:changes)
      %{apples: "green", bananas: "blue", oranges: "purple"}

  """
  def derive_if_missing(changeset, from_field_or_fields, to_field, fun) do
    case field_values(changeset, from_field_or_fields) do
      nil -> changeset
      inputs -> defaulted(changeset, to_field, fun.(inputs))
    end
  end

  @doc """
  Validates that at least one of the provided fields are present in the changeset.

  If the value of a field is `nil` or a string made only of whitespace,
  the changeset is marked as invalid and an error is added. Note the
  error won't be added though if the field already has an error.

  ## Options
    * `:message` - the message on failure, defaults to "at least one of apples can't be blank"
    * `:trim` - a boolean that sets whether whitespaces are removed before
      running the validation on binaries/strings, defaults to true

  ## Examples

      iex> ChangesetMerger.create(%{}, %{apples: :string})
      ...> |> ChangesetMerger.validate_all_not_empty([:apples])
      ...> |> Map.get(:errors)
      [apples: {"at least one of apples must be provided", [validation: :all_not_empty]}]

      iex> ChangesetMerger.create(%{}, %{apples: :string, bananas: :string})
      ...> |> ChangesetMerger.validate_all_not_empty([:apples, :bananas])
      ...> |> Map.get(:errors)
      [apples: {"at least one of apples, bananas must be provided", [validation: :all_not_empty]}, bananas: {"at least one of apples, bananas must be provided", [validation: :all_not_empty]}]

      iex> ChangesetMerger.create(%{apples: "a"}, %{apples: :string, bananas: :string})
      ...> |> ChangesetMerger.validate_all_not_empty([:apples, :bananas])
      ...> |> Map.get(:errors)
      []

      iex> ChangesetMerger.create(%{bananas: "b"}, %{apples: :string, bananas: :string})
      ...> |> ChangesetMerger.validate_all_not_empty([:apples, :bananas])
      ...> |> Map.get(:errors)
      []

      iex> ChangesetMerger.create(%{apples: "a", bananas: "b"}, %{apples: :string, bananas: :string})
      ...> |> ChangesetMerger.validate_all_not_empty([:apples, :bananas])
      ...> |> Map.get(:errors)
      []

  """
  def validate_all_not_empty(changeset, fields, opts \\ []) do
    %{required: required, errors: errors, changes: changes} = changeset

    message =
      Keyword.get(opts, :message, "at least one of #{Enum.join(fields, ", ")} must be provided")

    fields
    |> Enum.map(&get_field(changeset, &1))
    |> Enum.reject(&empty?/1)
    |> Enum.count()
    |> case do
      0 ->
        new_errors = Enum.map(fields, &{&1, {message, [validation: :all_not_empty]}})
        changes = Map.drop(changes, fields)

        %{
          changeset
          | changes: changes,
            required: fields ++ required,
            errors: new_errors ++ errors,
            valid?: false
        }

      _ ->
        changeset
    end
  end

  @doc """
  Changesets can run without a "changeset", by passing a tuple
  containing both the data and the supported types as a tuple instead of a struct:

  A convenience function to generate a changeset without a struct like `%User{}`.

      ChangesetMerger.create(
        %{"first_name" => "Andrew"},
        %{first_name: :string, last_name: :string, email: :string})

  If you want to seed the underlying mode, then use the &create/3 function
      ChangesetMerger.create(
        %{"first_name" => "Normal Andrew"},
        %{"first_name" => "Super Andrew"},
        %{first_name: :string, last_name: :string, email: :string})
  """
  def create(params, types), do: create(%{}, params, types)

  def create(record, params, types) do
    {record, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
  end

  defp field_values(changeset, from_fields) when is_list(from_fields) do
    Enum.map(from_fields, &get_field(changeset, &1))
  end

  defp field_values(changeset, from_field) do
    get_field(changeset, from_field)
  end

  defp put_change_if(changeset, to_field, val) do
    if get_field(changeset, to_field) == val do
      changeset
    else
      put_change(changeset, to_field, val)
    end
  end

  defp empty?(nil), do: true
  defp empty?(input) when is_binary(input), do: String.trim(input) == ""
  defp empty?(_), do: false
end
