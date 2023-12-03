defmodule GearRatios do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      number_ranges =
        Regex.scan(~r/\d+/, line, return: :index)
        |> Enum.map(fn [{start, length}] -> {start, start + length - 1} end)

      numbers =
        Regex.scan(~r/\d+/, line)
        |> Enum.map(&String.to_integer(Enum.at(&1, 0)))

      symbol_ranges =
        Regex.scan(~r/[^[:alnum:]\.]+/, line, return: :index)
        |> Enum.map(fn [{start, _}] -> start end)

      gear_ranges =
        Regex.scan(~r/\*+/, line, return: :index)
        |> Enum.map(fn [{start, _}] -> start end)

      {numbers, number_ranges, symbol_ranges, gear_ranges}
    end)
  end

  def get_part_numbers({{_numbers, _num_indices, []}, _index}, _), do: []

  def get_part_numbers({{numbers, number_ranges, symbols}, index}, input) do
    Enum.flat_map(symbols, fn symbol_index ->
      {{above_nums, above_nums_ranges, _}, _} = Enum.at(input, index - 1)
      {{below_nums, below_nums_ranges, _}, _} = Enum.at(input, index + 1)

      found_same_line = check_symbol_neighbours(symbol_index, number_ranges, numbers)
      found_above = check_symbol_neighbours(symbol_index, above_nums_ranges, above_nums)
      found_below = check_symbol_neighbours(symbol_index, below_nums_ranges, below_nums)

      found_same_line ++ found_above ++ found_below
    end)
  end

  def check_symbol_neighbours(symbol_index, number_ranges, numbers) do
    number_ranges
    |> Enum.with_index()
    |> Enum.flat_map(fn {{s, e}, i} ->
      cond do
        symbol_index >= s - 1 and symbol_index <= e + 1 -> [Enum.at(numbers, i)]
        true -> []
      end
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(fn {a, b, c, _} -> {a, b, c} end)
    |> Enum.with_index()
    |> then(&Enum.flat_map(&1, fn line -> get_part_numbers(line, &1) end))
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(fn {a, b, _, d} -> {a, b, d} end)
    |> Enum.with_index()
    |> then(
      &Enum.flat_map(&1, fn line ->
        line
        |> get_part_numbers(&1)
        |> case do
          [one, two] -> [one * two]
          _ -> []
        end
      end)
    )
    |> Enum.sum()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

GearRatios.part_1(input)
GearRatios.part_2(input)
