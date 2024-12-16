defmodule MullItOver do
  def parse_input(input) do
    ~r"mul\((\d+),(\d+)\)|(do\(\)|don't\(\))"
    |> Regex.scan(input)
    |> Enum.map(fn
      [_, "", "", "don't()"] ->
        :dont

      [_, "", "", "do()"] ->
        :do

      [_, x, y] ->
        [String.to_integer(x), String.to_integer(y)]
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(fn
      [x, y] ->
        x * y

      _ ->
        0
    end)
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.reduce({0, :do}, fn
      [x, y], {sum, :do} ->
        {sum + x * y, :do}

      [_, _], {sum, :dont} ->
        {sum, :dont}

      x, {sum, _} ->
        {sum, x}
    end)
    |> elem(0)
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

MullItOver.part_1(input)
MullItOver.part_2(input)
