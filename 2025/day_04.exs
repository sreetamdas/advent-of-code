defmodule PrintingDepartment do
  defp parse_input(lines) do
    lines
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp at(rows, i, j), do: Enum.at(Enum.at(rows, i), j)

  defp get_adjacency_count(rows = [row | _]) do
    cols_length = length(rows) - 1
    rows_length = length(row) - 1

    for r <- 0..rows_length, into: [] do
      for c <- 0..cols_length, into: [] do
        for y <- [-1, 0, 1], x <- [-1, 0, 1], reduce: 0 do
          count ->
            {i, j} = {r + y, c + x}

            cond do
              i >= 0 and i <= rows_length and
                j >= 0 and j <= cols_length and
                  at(rows, i, j) == "@" ->
                count + 1

              true ->
                count
            end
        end
        |> then(&{&1, at(rows, r, c)})
      end
    end
  end

  defp remove_rolls(rows) do
    Enum.reduce(rows, {0, []}, fn row, {outer_count, updated_rows} ->
      Enum.reduce(row, {outer_count, []}, fn
        {neighbours, x}, {inner_count, updated_row} ->
          cond do
            neighbours <= 4 and x == "@" ->
              {inner_count + 1, ["." | updated_row]}

            true ->
              {inner_count, [x | updated_row]}
          end
      end)
      |> then(fn {inner_count, updated_row} ->
        {inner_count, [Enum.reverse(updated_row) | updated_rows]}
      end)
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> get_adjacency_count()
    |> List.flatten()
    |> Enum.filter(fn
      {count, "@"} when count <= 4 -> true
      _ -> false
    end)
    |> Enum.count()
  end

  def part_2(input) do
    Stream.unfold({0, {0, parse_input(input)}}, fn
      {:halt, _} ->
        nil

      {total_count, {0, _prev_rows}} when total_count != 0 ->
        {total_count, {:halt, total_count}}

      {total_count, {_prev_count, prev_rows}} = x ->
        prev_rows
        |> get_adjacency_count()
        |> remove_rolls()
        |> then(fn {curr_count, curr_rows} ->
          {x, {total_count + curr_count, {curr_count, curr_rows}}}
        end)
    end)
    |> Enum.at(-1)
  end
end

# ##### With input prod #####
# Name             ips        average  deviation         median         99th %
# part_1         43.62       0.0229 s     ±8.08%       0.0218 s       0.0288 s
# part_2          0.65         1.54 s     ±0.63%         1.54 s         1.55 s

# Comparison:
# part_1         43.62
# part_2          0.65 - 67.19x slower +1.52 s

# Memory usage statistics:

# Name      Memory usage
# part_1        13.31 MB
# part_2       831.57 MB - 62.49x memory usage +818.27 MB
