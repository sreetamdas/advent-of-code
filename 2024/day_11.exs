defmodule PlutonianPebbles do
  def parse_input(input) do
    input
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  def split_recursively(_, 0), do: 1
  def split_recursively(0, blink_count), do: split_recursively(1, blink_count - 1)

  def split_recursively(stone_num, blink_count) do
    case :ets.lookup(:aoc_2024_day_11, [stone_num, blink_count]) do
      [{_, res} | _] ->
        res

      [] ->
        digits = Integer.digits(stone_num)

        cond do
          Integer.mod(length(digits), 2) == 0 ->
            digits
            |> Enum.split(div(length(digits), 2))
            |> then(fn {left, right} ->
              split_recursively(Integer.undigits(left), blink_count - 1) +
                split_recursively(Integer.undigits(right), blink_count - 1)
            end)

          true ->
            split_recursively(stone_num * 2024, blink_count - 1)
        end
        |> then(fn res ->
          :ets.insert(:aoc_2024_day_11, {[stone_num, blink_count], res})
          res
        end)
    end
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(&split_recursively(&1, 25))
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(&split_recursively(&1, 75))
    |> Enum.sum()
    |> IO.inspect(label: "part_2")
  end
end

:ets.new(:aoc_2024_day_11, [:named_table])
input = File.read!("input_11.txt")
PlutonianPebbles.part_1(input)
PlutonianPebbles.part_2(input)
:ets.delete(:aoc_2024_day_11)

# Benchee
# ##### With input puzzle #####
# Name             ips        average  deviation         median         99th %
# part_1        1.80 M      556.40 ns  ±2007.92%         500 ns         708 ns
# part_2        1.65 M      604.82 ns  ±2748.20%         542 ns         750 ns

# Comparison:
# part_1        1.80 M
# part_2        1.65 M - 1.09x slower +48.42 ns
