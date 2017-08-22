defmodule ChangesetMerger.ConfigTest do
  use ExUnit.Case
  doctest ChangesetMerger.Config
  alias ChangesetMerger.Config

  setup do
    System.put_env("CSM_ABC", "abc")
    System.put_env("CSM_DEF", "def")
    on_exit fn ->
      System.delete_env("CSM_ABC")
      System.delete_env("CSM_DEF")
    end
    :ok
  end

  test "resolve nothing to do" do
    assert 1 == Config.resolve(1)
    assert :a == Config.resolve(:a)
    assert "b" == Config.resolve("b")
    assert ["c", "d", "e"] == Config.resolve(["c", "d", "e"])
  end

  test "resolve env variable (missing)" do
    assert_raise RuntimeError, "Missing env variable(s) XXX", fn ->
      Config.resolve("${XXX}")
    end
  end

  test "resolve env variables" do
    assert "abc" == Config.resolve("${CSM_ABC}")
    assert "def" == Config.resolve("${CSM_DEF}")
    assert "abc_def" == Config.resolve("${CSM_ABC}_${CSM_DEF}")
    assert "_abc_abc_def_" == Config.resolve("_${CSM_ABC}_${CSM_ABC}_${CSM_DEF}_")
  end

  test "resolve lists" do
    assert ["abc", "def", "xxx"] == Config.resolve(["${CSM_ABC}", "${CSM_DEF}", "xxx"])
  end

  test "resolve maps" do
    assert %{a: "abc", b: "def", c: "xxx"} == Config.resolve(%{a: "${CSM_ABC}", b: "${CSM_DEF}", c: "xxx"})
  end


  test "init (nothing to do)" do
    untouched = %{one: 1, a: :a, b: "b", c: ["c", "d", "e"]}
    assert {:ok, untouched} == Config.init(untouched)
  end

  test "resolve all variables" do
    System.put_env("CSM_ABC", "abc")
    System.put_env("CSM_DEF", "def")
    assert {:ok, %{a: "abc", b: "abc_def"}} == Config.init(%{a: "${CSM_ABC}", b: "${CSM_ABC}_${CSM_DEF}"})
  end

end