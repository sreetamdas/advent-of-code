defmodule GiftShop do
  defp parse_input(lines) do
    lines
    |> String.split(",")
    |> Enum.map(fn range ->
      range
      |> String.split("-")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp check_invalid(num) do
    num
    |> Integer.digits()
    |> then(fn digits ->
      len = length(digits)

      digits
      |> Enum.split(div(len, 2))
      |> then(fn {first, second} ->
        cond do
          first == second -> [num]
          true -> []
        end
      end)
    end)
  end

  defp invalid_in_range([start, finish]) do
    start..finish
    |> Enum.flat_map(&check_invalid/1)
  end

  def factors(n) when is_integer(n) do
    upper_range = floor(:math.sqrt(n))
    factors = for x <- 1..upper_range, rem(n, x) == 0, do: [x, div(n, x)]
    List.flatten(factors) |> Enum.dedup() |> Enum.sort()
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.flat_map(&invalid_in_range/1)
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(fn range = [range_start, range_finish] ->
      range
      |> Enum.map(&Integer.digits/1)
      |> then(fn range_ends ->
        range_ends
        |> Enum.map(fn range_end ->
          digit_count = length(range_end)

          (factors(digit_count) -- [digit_count])
          |> Enum.map(fn len ->
            range_ends
            |> Enum.map(&Enum.take(&1, len))
            |> then(fn some_digits ->
              some_digits
              |> Enum.map(&Integer.undigits/1)
              |> then(fn [start, finish] ->
                if finish < start do
                  start..(finish * 10)
                else
                  start..finish
                end
                |> Enum.map(fn num ->
                  repeat_count = div(digit_count, length(Integer.digits(start)))

                  num
                  |> Integer.digits()
                  |> Enum.take(len)
                  |> List.duplicate(repeat_count)
                  |> List.flatten()
                  |> Integer.undigits()
                end)
              end)
            end)
          end)
        end)
        |> List.flatten()
        |> Enum.uniq()
      end)
      |> then(fn constructed_nums ->
        constructed_nums
        |> Enum.filter(&Enum.member?(range_start..range_finish, &1))
      end)
    end)
    |> List.flatten()
    |> Enum.sort()
    |> Enum.sum()
    |> IO.inspect(label: "part_2")
  end
end

input = AdventOfCode.Helpers.file_input(__ENV__.file)

GiftShop.part_1(input)
GiftShop.part_2(input)
