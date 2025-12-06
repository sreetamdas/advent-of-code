defmodule TrashCompactor do
  defp parse_input(lines), do: lines |> String.trim() |> String.split("\n")

  defp parse_line(line) do
    Enum.flat_map(line, fn
      "*" -> [&Kernel.*/2]
      "+" -> [&Kernel.+/2]
      " " -> []
      num -> [String.to_integer(num)]
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(
      &(String.trim(&1)
        |> String.split(" ", trim: true)
        |> parse_line())
    )
    |> Enum.reverse()
    |> Enum.zip_with(&Function.identity/1)
    |> Enum.map(fn [op | [first | nums]] -> Enum.reduce(nums, first, &op.(&1, &2)) end)
    |> Enum.sum()
  end

  def part_2(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> then(
      &case {length(List.last(&1)), length(List.first(&1))} do
        {x, y} when x < y ->
          List.replace_at(&1, -1, List.last(&1) ++ List.duplicate(" ", y - x))

        _ ->
          &1
      end
    )
    |> Enum.zip_with(&Function.identity/1)
    |> Enum.map(&parse_line/1)
    |> Enum.reduce({nil, nil, 0}, fn
      [], {_op, chunk_total, grand_total} ->
        {nil, nil, grand_total + chunk_total}

      num_with_op, {nil, nil, total} ->
        {List.last(num_with_op), Integer.undigits(Enum.slice(num_with_op, 0..-2//1)), total}

      num, {op, chunk_total, grand_total} ->
        {op, op.(chunk_total, Integer.undigits(num)), grand_total}
    end)
    |> then(fn {_, chunk, total} -> total + chunk end)
  end
end

# ##### With input prod #####
# Name             ips        average  deviation         median         99th %
# part_1        3.00 K        0.33 ms     ±8.56%        0.33 ms        0.41 ms
# part_2        0.81 K        1.23 ms     ±4.87%        1.23 ms        1.38 ms

# Comparison:
# part_1        3.00 K
# part_2        0.81 K - 3.70x slower +0.90 ms

# Memory usage statistics:

# Name      Memory usage
# part_1         0.84 MB
# part_2         5.36 MB - 6.37x memory usage +4.52 MB
