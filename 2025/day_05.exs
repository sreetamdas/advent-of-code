defmodule Cafeteria do
  defp parse_input(lines) do
    lines
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(fn block ->
      block
      |> String.split("\n")
      |> Enum.map(fn
        line ->
          line
          |> String.split("-")
          |> then(fn
            [start, finish] -> {String.to_integer(start), String.to_integer(finish)}
            [x] -> String.to_integer(x)
          end)
      end)
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> then(fn [ranges, ingredients] ->
      Enum.reduce(ingredients, 0, fn
        ingredient, count ->
          if Enum.any?(ranges, &(ingredient in elem(&1, 0)..elem(&1, 1))),
            do: count + 1,
            else: count
      end)
    end)
  end

  def part_2(input) do
    input
    |> parse_input()
    |> then(fn [ranges, _ingredients] ->
      ranges
      |> Enum.sort_by(fn {start, _} -> start end)
      |> Enum.reduce({0, -1}, fn
        {start, finish}, {total, prev_finish} ->
          {curr_start, curr_finish} =
            {Enum.max([start, prev_finish + 1]), Enum.max([prev_finish, finish])}

          count = if curr_start <= finish, do: finish - curr_start + 1, else: 0

          {total + count, curr_finish}
      end)
      |> elem(0)
    end)
  end
end

# ##### With input prod #####
# Name             ips        average  deviation         median         99th %
# part_2        6.29 K       0.159 ms     ±5.42%       0.158 ms       0.181 ms
# part_1        0.46 K        2.19 ms     ±2.80%        2.19 ms        2.28 ms

# Comparison:
# part_2        6.29 K
# part_1        0.46 K - 13.77x slower +2.03 ms

# Memory usage statistics:

# Name      Memory usage
# part_2       0.0912 MB
# part_1         5.90 MB - 64.72x memory usage +5.81 MB
