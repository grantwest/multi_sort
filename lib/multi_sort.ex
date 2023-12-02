defmodule MultiSort do
  @moduledoc """
  Documentation for `MultiSort`.
  """

  @type order() :: :asc | :desc
  @type map_fn() :: (any() -> any())
  @type compare_fn() :: (any(), any() -> :eq | :lt | :gt)
  @type comparator() ::
          {order(), map_fn()}
          | {order(), map_fn(), compare_fn()}
          | {order(), map_fn(), module()}
          | {order(), map_fn(), list()}

  @doc """
  Sort an enum according to a priortized list of comparators. Inspired by Ecto/SQL order by.

  Sort posts first by title and then by descending date:
      posts
      |> MultiSort.by([
          {:asc, &1.title}
          # Pass Date module as third element because we need to use Date.compare/2 to compare dates
          {:desc, &1.date, Date},
      ])

  Sort posts first by category according to order list and then by title:
      post_category_order = [:business, :sports, :politics]
      posts
      |> MultiSort.by([
          {:asc, &1.category, post_category_order},
          {:asc, &1.title}
      ])

  The third element of the tuple can either be:
  - Left out entirely, resuting in the default elixir comparison
  - Be a module with a compare/2 function
  - Be a function that takes 2 arguemnts and returns :eq, :lt, or :gt
  - Be a list that describes sort order
  """
  @spec by(Enum.t(), list(comparator())) :: list()
  def by(list, comparators) do
    Enum.sort(list, compound_comparator(comparators))
  end

  def compound_comparator(comparators) do
    if Enum.empty?(comparators), do: raise(ArgumentError)
    if Enum.any?(comparators, &(!is_tuple(&1))), do: raise("all comparators must be tuples")
    comparators = Enum.map(comparators, &normalize_comparator/1)

    fn a, b ->
      eval_compound_comparator(a, b, comparators)
    end
  end

  defp eval_compound_comparator(_a, _b, []), do: true

  defp eval_compound_comparator(a, b, [{order, mapper, compare_fn} | comparators]) do
    a_val = mapper.(a)
    b_val = mapper.(b)

    case {order, compare_fn.(a_val, b_val)} do
      {_, :eq} -> eval_compound_comparator(a, b, comparators)
      {:asc, :lt} -> true
      {:asc, :gt} -> false
      {:desc, :lt} -> false
      {:desc, :gt} -> true
    end
  end

  defp normalize_comparator(comparator) do
    case comparator do
      {order, mapper} when is_function(mapper, 1) ->
        {order, mapper, &default_compare_fn/2}

      {order, mapper, compare_fn} when is_function(mapper, 1) and is_function(compare_fn, 2) ->
        {order, mapper, compare_fn}

      {order, mapper, module} when is_function(mapper, 1) and is_atom(module) ->
        {order, mapper, &module.compare/2}

      {order, mapper, rank} when is_function(mapper, 1) and is_list(rank) ->
        rank_map = rank_map(rank)
        {order, &Map.fetch!(rank_map, mapper.(&1)), &default_compare_fn/2}
    end
  end

  defp default_compare_fn(a, b) do
    cond do
      a == b -> :eq
      a < b -> :lt
      true -> :gt
    end
  end

  defp rank_map(list), do: Enum.with_index(list) |> Map.new()
end
