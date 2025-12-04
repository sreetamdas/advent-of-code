defmodule PrintingDepartment do
  defp parse_input(lines) do
    lines
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp at(rows, i, j, use_cache) do
    if use_cache do
      case :ets.lookup(:aoc_2025_day_04, {i, j}) do
        [] ->
          curr = Enum.at(Enum.at(rows, i), j)
          :ets.insert(:aoc_2025_day_04, {{i, j}, curr})

          curr

        [{_, val}] ->
          val
      end
    else
      Enum.at(Enum.at(rows, i), j)
    end
  end

  defp get_adjacency_count(rows = [row | _], use_cache \\ false) do
    cols_length = length(rows) - 1
    rows_length = length(row) - 1

    for r <- 0..rows_length, reduce: {0, []} do
      {outer_removed_count, updated_rows} ->
        for c <- 0..cols_length, reduce: {outer_removed_count, []} do
          {inner_removed_count, updated_row} ->
            curr = at(rows, r, c, use_cache)

            for y <- [-1, 0, 1], x <- [-1, 0, 1], reduce: 0 do
              count ->
                {i, j} = {r + y, c + x}

                cond do
                  i >= 0 and i <= rows_length and
                    j >= 0 and j <= cols_length and
                    count <= 4 and at(rows, i, j, use_cache) == "@" ->
                    count + 1

                  true ->
                    count
                end
            end
            |> then(fn neighbours_count ->
              cond do
                neighbours_count <= 4 and curr == "@" ->
                  if use_cache do
                    :ets.insert(:aoc_2025_day_04, {{r, c}, "."})
                  end

                  {inner_removed_count + 1, ["." | updated_row]}

                true ->
                  {inner_removed_count, [curr | updated_row]}
              end
            end)
        end
        |> then(fn {inner_removed_count, updated_row} ->
          {inner_removed_count, [Enum.reverse(updated_row) | updated_rows]}
        end)
    end
  end

  def part_1(input) do
    input
    |> parse_input()
    |> get_adjacency_count()
    |> elem(0)
  end

  def part_2(input) do
    :ets.new(:aoc_2025_day_04, [:named_table])

    final_count =
      Stream.unfold({0, {0, parse_input(input)}}, fn
        {:halt, _} ->
          nil

        {total_count, {0, _prev_rows}} when total_count != 0 ->
          {total_count, {:halt, total_count}}

        {total_count, {_prev_count, prev_rows}} = x ->
          prev_rows
          |> get_adjacency_count(true)
          |> then(fn {curr_count, curr_rows} ->
            {x, {total_count + curr_count, {curr_count, curr_rows}}}
          end)
      end)
      |> Enum.at(-1)

    :ets.delete(:aoc_2025_day_04)

    final_count
  end
end

# ##### With input prod #####
# Name             ips        average  deviation         median         99th %
# part_1         40.42       24.74 ms    ±43.96%       20.47 ms       51.11 ms
# part_2          1.70      587.34 ms     ±1.23%      585.64 ms      598.17 ms

# Comparison:
# part_1         40.42
# part_2          1.70 - 23.74x slower +562.60 ms

# Memory usage statistics:

# Name      Memory usage
# part_1       0.0126 GB
# part_2         1.30 GB - 103.05x memory usage +1.29 GB
