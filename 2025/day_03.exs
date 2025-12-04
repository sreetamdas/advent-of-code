defmodule Lobby do
  defp parse_input(lines) do
    lines
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.trim()
      |> String.to_integer()
    end)
  end

  defp get_largest_num(num, digit_count) do
    num
    |> Integer.digits()
    |> then(fn digits ->
      digits
      |> Enum.with_index()
      |> then(fn digits_with_index ->
        digits_with_index
        |> Enum.reduce_while({{0, -digit_count}, []}, fn _, {{start, finish}, list} ->
          digits_with_index
          |> Enum.slice(start..finish//1)
          |> then(fn slice ->
            slice
            |> Enum.max_by(&elem(&1, 0), fn -> {Enum.at(list, 0), start} end)
            |> case do
              {curr_max_num, _} when finish == -1 ->
                [curr_max_num | list]
                |> Enum.reverse()
                |> Integer.undigits()
                |> then(&{:halt, &1})

              {curr_max_num, curr_max_index} ->
                {:cont, {{curr_max_index + 1, finish + 1}, [curr_max_num | list]}}
            end
          end)
        end)
      end)
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(&get_largest_num(&1, 2))
    |> Enum.sum()
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(&get_largest_num(&1, 12))
    |> Enum.sum()
  end
end

# ##### With input prod #####
# Name             ips        average  deviation         median         99th %
# part_1        877.66        1.14 ms     ±8.53%        1.13 ms        1.24 ms
# part_2        569.18        1.76 ms     ±1.73%        1.76 ms        1.83 ms

# Comparison:
# part_1        877.66
# part_2        569.18 - 1.54x slower +0.62 ms

# Memory usage statistics:

# Name      Memory usage
# part_1         1.66 MB
# part_2         2.84 MB - 1.71x memory usage +1.19 MB
