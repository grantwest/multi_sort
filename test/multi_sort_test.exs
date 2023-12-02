defmodule MultiSortTest do
  use ExUnit.Case, async: true

  doctest MultiSort

  describe "MultiSort.by" do
    test "empty list" do
      sorted = MultiSort.by([], [{:asc, & &1}])
      assert sorted == []
    end

    test "asc and desc" do
      list = [
        {0, 1},
        {0, 0},
        {1, 1},
        {1, 0},
        {2, 1},
        {2, 0}
      ]

      unsorted = Enum.shuffle(list)

      sorted =
        MultiSort.by(unsorted, [
          {:asc, &elem(&1, 0)},
          {:desc, &elem(&1, 1)}
        ])

      assert sorted == list
    end

    test "sort dates (or anything with special compare function)" do
      dates = [
        ~N[2023-12-02 18:01:22],
        ~N[2023-12-02 18:01:23],
        ~N[2023-12-02 18:01:21]
      ]

      assert MultiSort.by(dates, [{:asc, & &1, NaiveDateTime}]) == [
               ~N[2023-12-02 18:01:21],
               ~N[2023-12-02 18:01:22],
               ~N[2023-12-02 18:01:23]
             ]

      assert MultiSort.by(dates, [{:desc, & &1, NaiveDateTime}]) == [
               ~N[2023-12-02 18:01:23],
               ~N[2023-12-02 18:01:22],
               ~N[2023-12-02 18:01:21]
             ]
    end

    test "sort with order list" do
      order = [
        :one,
        :two,
        :three,
        :four,
        :five
      ]

      list = [
        :two,
        :five,
        :three,
        :one,
        :four
      ]

      assert MultiSort.by(list, [{:asc, & &1, order}]) == [
               :one,
               :two,
               :three,
               :four,
               :five
             ]

      assert MultiSort.by(list, [{:desc, & &1, order}]) == [
               :five,
               :four,
               :three,
               :two,
               :one
             ]
    end
  end

  describe "compound_comparator" do
    test "empty list" do
      comparator = MultiSort.compound_comparator([{:asc, & &1}])
      assert Enum.sort([], comparator) == []
    end

    test "simple numbers" do
      comparator = MultiSort.compound_comparator([{:asc, & &1}])
      assert Enum.sort([3, 1, 2], comparator) == [1, 2, 3]
    end

    test "single comparator compare and equality" do
      comparator = MultiSort.compound_comparator([{:asc, & &1}])

      # The given function should compare two arguments, and return
      # true if the first argument precedes or is in the same place as the second one.
      assert comparator.(1, 2) == true
      assert comparator.(1, 1) == true
      assert comparator.(2, 1) == false
    end

    test "double comparator compare and equality ascending" do
      comparator =
        MultiSort.compound_comparator([
          {:asc, &elem(&1, 0)},
          {:asc, &elem(&1, 1)}
        ])

      # The given function should compare two arguments, and return
      # true if the first argument precedes or is in the same place as the second one.
      assert comparator.({1, 1}, {0, 0}) == false
      assert comparator.({1, 1}, {0, 1}) == false
      assert comparator.({1, 1}, {0, 2}) == false
      assert comparator.({1, 1}, {1, 0}) == false
      assert comparator.({1, 1}, {1, 1}) == true
      assert comparator.({1, 1}, {1, 2}) == true
      assert comparator.({1, 1}, {2, 0}) == true
      assert comparator.({1, 1}, {2, 1}) == true
      assert comparator.({1, 1}, {2, 2}) == true
    end

    test "double comparator compare and equality descending" do
      comparator =
        MultiSort.compound_comparator([
          {:desc, &elem(&1, 0)},
          {:desc, &elem(&1, 1)}
        ])

      # The given function should compare two arguments, and return
      # true if the first argument precedes or is in the same place as the second one.
      assert comparator.({1, 1}, {0, 0}) == true
      assert comparator.({1, 1}, {0, 1}) == true
      assert comparator.({1, 1}, {0, 2}) == true
      assert comparator.({1, 1}, {1, 0}) == true
      assert comparator.({1, 1}, {1, 1}) == true
      assert comparator.({1, 1}, {1, 2}) == false
      assert comparator.({1, 1}, {2, 0}) == false
      assert comparator.({1, 1}, {2, 1}) == false
      assert comparator.({1, 1}, {2, 2}) == false
    end

    test "double comparator compare and equality ascending & descending" do
      comparator =
        MultiSort.compound_comparator([
          {:asc, &elem(&1, 0)},
          {:desc, &elem(&1, 1)}
        ])

      # The given function should compare two arguments, and return
      # true if the first argument precedes or is in the same place as the second one.
      assert comparator.({1, 1}, {0, 2}) == false
      assert comparator.({1, 1}, {0, 1}) == false
      assert comparator.({1, 1}, {0, 0}) == false
      assert comparator.({1, 1}, {1, 2}) == false
      assert comparator.({1, 1}, {1, 1}) == true
      assert comparator.({1, 1}, {1, 0}) == true
      assert comparator.({1, 1}, {2, 2}) == true
      assert comparator.({1, 1}, {2, 1}) == true
      assert comparator.({1, 1}, {2, 0}) == true
    end
  end
end
