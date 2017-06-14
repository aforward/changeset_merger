defmodule ChangesetMergerTest do
  use ExUnit.Case
  doctest ChangesetMerger
  doctest ChangesetMerger.Slug
  doctest ChangesetMerger.Token
  doctest ChangesetMerger.ExpiresAt

  defstruct apples: nil

  test "handle struct" do
    changes = ChangesetMerger.create(%ChangesetMergerTest{apples: "red"}, %{}, %{apples: :string})
      |> ChangesetMerger.defaulted(:apples, "blue")
      |> Map.get(:changes)

    assert changes == %{}
  end
end
