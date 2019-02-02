defmodule ChangesetMerger.ExpiresAt do
  @moduledoc """
  Several helper functions to generate date/time values to represent
  an expiring value.
  """

  @doc """
  Generate an unguessable (non incremented) public token_expires_at

  ## Examples

      iex> ChangesetMerger.ExpiresAt.generate("2017-09-21T04:50:34-05:00", 2, :days)
      #DateTime<2017-09-23 09:50:34Z>

      iex> ChangesetMerger.ExpiresAt.generate("2017-09-21T04:50:34-05:00", 3, :minutes)
      #DateTime<2017-09-21 09:53:34Z>

      iex> ChangesetMerger.ExpiresAt.generate("2019-02-04 21:40:15.397138Z", 3, :minutes)
      #DateTime<2019-02-04 21:43:15Z>
  """
  def generate(num, units) do
    DateTime.utc_now()
    |> generate(num, units)
  end

  def generate(nil, num, units), do: generate(num, units)

  def generate(start_date_time, num, units) when is_binary(start_date_time) do
    start_date_time
    |> from_iso8601()
    |> generate(num, units)
  end

  def generate(start_date_time, num, :days) do
    generate(start_date_time, num * 60 * 60 * 24, :second)
  end

  def generate(start_date_time, num, :minutes) do
    generate(start_date_time, num * 60, :second)
  end

  def generate(start_date_time, num, :second) do
    start_date_time
    |> DateTime.add(num, :second)
    |> DateTime.truncate(:second)
  end

  @doc """
  Add a token to your changeset if none is already set

  ## Examples

      iex> ChangesetMerger.create(%{"token_expires_at" => ChangesetMerger.ExpiresAt.from_iso8601("2015-09-21T04:50:34-05:00")}, %{token_expires_at: :utc_datetime})
      ...> |> ChangesetMerger.ExpiresAt.defaulted(:token_expires_at, "2017-09-21T04:50:34-05:00", 1, :days)
      ...> |> Map.get(:changes)
      ...> |> Map.get(:token_expires_at)
      #DateTime<2015-09-21 09:50:34Z>

      iex> ChangesetMerger.create(%{"token_expires_at" => nil}, %{token_expires_at: :utc_datetime})
      ...> |> ChangesetMerger.ExpiresAt.defaulted(:token_expires_at, "2017-09-21T04:50:34-05:00", 1, :days)
      ...> |> Map.get(:changes)
      ...> |> Map.get(:token_expires_at)
      #DateTime<2017-09-22 09:50:34Z>

  """
  def defaulted(changeset, field, num, units), do: defaulted(changeset, field, nil, num, units)

  def defaulted(changeset, field, start_date_time, num, units) do
    ChangesetMerger.defaulted(changeset, field, generate(start_date_time, num, units))
  end

  @doc """
  Set a new token to your changeset

  ## Examples

      iex> ChangesetMerger.create(%{"token_expires_at" => ChangesetMerger.ExpiresAt.from_iso8601("2015-09-21T04:50:34-05:00")}, %{token_expires_at: :utc_datetime})
      ...> |> ChangesetMerger.ExpiresAt.force(:token_expires_at, "2017-09-21T04:50:34-05:00", 1, :days)
      ...> |> Map.get(:changes)
      ...> |> Map.get(:token_expires_at)
      #DateTime<2017-09-22 09:50:34Z>

      iex> ChangesetMerger.create(%{"token_expires_at" => nil}, %{token_expires_at: :utc_datetime})
      ...> |> ChangesetMerger.ExpiresAt.force(:token_expires_at, "2017-09-21T04:50:34-05:00", 1, :days)
      ...> |> Map.get(:changes)
      ...> |> Map.get(:token_expires_at)
      #DateTime<2017-09-22 09:50:34Z>

  """
  def force(changeset, field, num, units), do: force(changeset, field, nil, num, units)

  def force(changeset, field, start_date_time, num, units) do
    ChangesetMerger.force(changeset, field, generate(start_date_time, num, units))
  end

  def from_iso8601(input) do
    input
    |> DateTime.from_iso8601()
    |> case do
      {:ok, dt, _offset} -> dt
    end
  end
end
