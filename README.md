# MultiSort

[![Build Status](https://github.com/grantwest/multi_sort/actions/workflows/ci.yml/badge.svg)](https://github.com/grantwest/multi_sort/actions/workflows/ci.yml)
[![Version](https://img.shields.io/hexpm/v/multi_sort.svg)](https://hex.pm/packages/multi_sort)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/multi_sort/)
[![Download](https://img.shields.io/hexpm/dt/multi_sort.svg)](https://hex.pm/packages/multi_sort)
[![License](https://img.shields.io/badge/License-0BSD-blue.svg)](https://opensource.org/licenses/0bsd)
[![Last Updated](https://img.shields.io/github/last-commit/grantwest/multi_sort.svg)](https://github.com/grantwest/multi_sort/commits/master)

Easily sort by multiple fields in a readable manner. Inspired by Ecto/SQL order by.

Sort posts first by title and then by descending date:

```elixir
posts
|> MultiSort.by([
    {:asc, &1.title}
    # Pass Date module as third element because we need to use Date.compare/2 to compare dates
    {:desc, &1.date, Date},
])
```

Sort posts first by category according to order list and then by title:

```elixir
post_category_order = [:business, :sports, :politics]
posts
|> MultiSort.by([
    {:asc, &1.category, post_category_order},
    {:asc, &1.title}
])
```

[See docs](https://hexdocs.pm/multi_sort/MultiSort.html) for more information and examples.
