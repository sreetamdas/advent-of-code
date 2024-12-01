defmodule HistorianHysteria do
  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split("   ")
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.reduce([[], []], fn [x, y], [first, second] ->
      [[x | first], [y | second]]
    end)
    |> Enum.map(&Enum.sort/1)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.zip()
    |> Enum.map(fn {x, y} -> abs(x - y) end)
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> then(fn [first, second] ->
      freqs =
        second
        |> Enum.frequencies()

      first
      |> Enum.map(&(&1 * Map.get(freqs, &1, 0)))
      |> Enum.sum()
      |> IO.inspect(label: "part_2")
    end)
  end
end

input = File.read!("input.txt")

HistorianHysteria.part_1(input)
HistorianHysteria.part_2(input)
