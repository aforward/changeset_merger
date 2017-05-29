defmodule ChangesetMerger.ExpiresAt do

  alias ChangesetMerger.ExpiresAt

  @doc"""
  Generate an unguessable (non incremented) public token_expires_at

  ## Examples

      iex> ChangesetMerger.ExpiresAt.generate("2017-09-21T04:50:34-05:00", 2, :days) |> Timex.format!("{ISO:Basic}")
      "20170923T045034-0500"

      iex> ChangesetMerger.ExpiresAt.generate("2017-09-21T04:50:34-05:00", 3, :minutes) |> Timex.format!("{ISO:Basic}")
      "20170921T045334-0500"
  """
  def generate(num, units) do
    Timex.now
    |> generate(num, units)
  end
  def generate(nil, num, units), do: generate(num, units)
  def generate(start_date_time, num, units) when is_binary(start_date_time) do
    start_date_time
    |> Timex.parse!("{ISO:Extended}")
    |> generate(num, units)
  end
  def generate(start_date_time, num, units) do
    start_date_time
    |> Timex.shift([{units, num}])
  end

  @doc"""
  Add a token to your changeset if none is already set

  ## Examples

      iex> ChangesetMerger.create(%{"token_expires_at" => Timex.parse!("2015-09-21T04:50:34-05:00", "{ISO:Extended}")}, %{token_expires_at: :utc_datetime})
      ...> |> ChangesetMerger.ExpiresAt.defaulted(:token_expires_at, "2017-09-21T04:50:34-05:00", 1, :days)
      ...> |> Map.get(:changes)
      ...> |> Map.get(:token_expires_at)
      ...> |> Timex.format!("{ISO:Basic}")
      "20150921T045034+0000"

      iex> ChangesetMerger.create(%{"token_expires_at" => nil}, %{token_expires_at: :utc_datetime})
      ...> |> ChangesetMerger.ExpiresAt.defaulted(:token_expires_at, "2017-09-21T04:50:34-05:00", 1, :days)
      ...> |> Map.get(:changes)
      ...> |> Map.get(:token_expires_at)
      ...> |> Timex.format!("{ISO:Basic}")
      "20170922T045034-0500"

  """
  def defaulted(changeset, field, num, units), do: defaulted(changeset, field, nil, num, units)
  def defaulted(changeset, field, start_date_time, num, units) do
    ChangesetMerger.defaulted(changeset, field, ExpiresAt.generate(start_date_time, num, units))
  end

  @doc"""
  Set a new token to your changeset

  ## Examples

      iex> ChangesetMerger.create(%{"token_expires_at" => Timex.parse!("2015-09-21T04:50:34-05:00", "{ISO:Extended}")}, %{token_expires_at: :utc_datetime})
      ...> |> ChangesetMerger.ExpiresAt.force(:token_expires_at, "2017-09-21T04:50:34-05:00", 1, :days)
      ...> |> Map.get(:changes)
      ...> |> Map.get(:token_expires_at)
      ...> |> Timex.format!("{ISO:Basic}")
      "20170922T045034-0500"

      iex> ChangesetMerger.create(%{"token_expires_at" => nil}, %{token_expires_at: :utc_datetime})
      ...> |> ChangesetMerger.ExpiresAt.force(:token_expires_at, "2017-09-21T04:50:34-05:00", 1, :days)
      ...> |> Map.get(:changes)
      ...> |> Map.get(:token_expires_at)
      ...> |> Timex.format!("{ISO:Basic}")
      "20170922T045034-0500"

  """
  def force(changeset, field, num, units), do: force(changeset, field, nil, num, units)
  def force(changeset, field, start_date_time, num, units) do
    ChangesetMerger.force(changeset, field, ExpiresAt.generate(start_date_time, num, units))
  end

end



