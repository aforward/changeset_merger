defmodule ChangesetMergerTest do
  use ExUnit.Case
  doctest ChangesetMerger
  doctest ChangesetMerger.Slug
  doctest ChangesetMerger.Token
  doctest ChangesetMerger.ExpiresAt

  test "the truth" do
    assert 1 + 1 == 2
  end
end
