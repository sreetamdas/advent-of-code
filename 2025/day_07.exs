defmodule Laboratories do
  defp parse_input(lines) do
    lines
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.trim()
      |> String.graphemes()
    end)
    |> then(fn [first | _] = parsed -> {Enum.find_index(first, &(&1 == "S")), parsed} end)
  end

  def part_1(input) do
    {start, [_first | rest]} = parse_input(input)

    rest
    |> Enum.reduce({0, [start]}, fn line, {total_splits, beam_indices} ->
      line
      |> Enum.with_index()
      |> Enum.reduce({total_splits, beam_indices}, fn {block, index}, {line_splits, line_indices} ->
        cond do
          block == "^" and Enum.member?(beam_indices, index) ->
            line_indices
            |> Enum.map(fn
              x when x == index -> [x - 1, x + 1]
              x -> x
            end)
            |> then(&{line_splits + 1, &1})

          true ->
            {line_splits, line_indices}
        end
      end)
      |> then(fn {line_splits, line_indices} ->
        line_indices
        |> List.flatten()
        |> Enum.uniq()
        |> then(&{line_splits, &1})
      end)
    end)
    |> elem(0)
  end

  def get_paths_count(input, {rows, cols} = limits, {x, y})
      when x >= 0 and x <= rows and
             y >= 0 and y <= cols do
    case :ets.lookup(:aoc_2025_day_07, {x, y}) do
      [] ->
        case Enum.at(Enum.at(input, x), y) do
          "^" ->
            get_paths_count(input, limits, {x + 1, y - 1}) +
              get_paths_count(input, limits, {x + 1, y + 1})

          _ ->
            get_paths_count(input, limits, {x + 1, y})
        end
        |> tap(&:ets.insert(:aoc_2025_day_07, {{x, y}, &1}))

      [{_, val}] ->
        val
    end
  end

  def get_paths_count(_, _, _), do: 1

  def part_2(input) do
    :ets.new(:aoc_2025_day_07, [:named_table])
    {start, [first | rest] = parsed_input} = parse_input(input)

    get_paths_count(parsed_input, {length(rest), length(first)}, {0, start})
    |> tap(fn _ -> :ets.delete(:aoc_2025_day_07) end)
  end
end

# ##### With input prod #####
# Name             ips        average  deviation         median         99th %
# part_1        439.05        2.28 ms     ±6.40%        2.28 ms        2.70 ms
# part_2        325.99        3.07 ms     ±4.87%        3.03 ms        3.55 ms

# Comparison:
# part_1        439.05
# part_2        325.99 - 1.35x slower +0.79 ms

# Memory usage statistics:

# Name      Memory usage
# part_1         6.78 MB
# part_2         3.33 MB - 0.49x memory usage -3.45100 MB
