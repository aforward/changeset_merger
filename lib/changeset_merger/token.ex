defmodule ChangesetMerger.Token do

  @doc """
  Generate an unguessable (non incremented) public identifier

  ## Examples

      iex> ChangesetMerger.Token.generate(20) |> String.length
      20

  """
  def generate(len), do: :crypto.strong_rand_bytes(len) |> Base.url_encode64 |> binary_part(0, len)

  @doc """
  Add a token to your changeset if none is already set

  ## Examples

      iex> ChangesetMerger.create(%{}, %{})
      ...> |> ChangesetMerger.Token.defaulted()
      ...> |> Map.get(:changes)
      ...> |> Map.get(:token)
      ...> |> String.length
      7

      iex> ChangesetMerger.create(%{}, %{})
      ...> |> ChangesetMerger.Token.defaulted(:identifier, 20)
      ...> |> Map.get(:changes)
      ...> |> Map.get(:identifier)
      ...> |> String.length
      20

      iex> ChangesetMerger.create(%{"identifier" => "gsmith123"}, %{identifier: :string})
      ...> |> ChangesetMerger.Token.defaulted(:identifier)
      ...> |> Map.get(:changes)
      %{identifier: "gsmith123"}

  """
  def defaulted(changeset), do: defaulted(changeset, :token)
  def defaulted(changeset, field), do: defaulted(changeset, field, 7)
  def defaulted(changeset, field, len) do
    ChangesetMerger.defaulted(changeset, field, ChangesetMerger.Token.generate(len))
  end

  @doc """
  Set a new token to your changeset

  ## Examples

      iex> ChangesetMerger.create(%{}, %{})
      ...> |> ChangesetMerger.Token.force()
      ...> |> Map.get(:changes)
      ...> |> Map.get(:token)
      ...> |> String.length
      7

      iex> ChangesetMerger.create(%{}, %{})
      ...> |> ChangesetMerger.Token.force(:identifier, 20)
      ...> |> Map.get(:changes)
      ...> |> Map.get(:identifier)
      ...> |> String.length
      20

      iex> ChangesetMerger.create(%{"identifier" => "gsmith123"}, %{identifier: :string})
      ...> |> ChangesetMerger.Token.force(:identifier, 20)
      ...> |> Map.get(:changes)
      ...> |> Map.get(:identifier)
      ...> |> String.length
      20

  """
  def force(changeset), do: force(changeset, :token)
  def force(changeset, field), do: force(changeset, field, 7)
  def force(changeset, field, len) do
    ChangesetMerger.force(changeset, field, ChangesetMerger.Token.generate(len))
  end

end



