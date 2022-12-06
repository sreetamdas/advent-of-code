defmodule CalorieCounting do
  @moduledoc """
  Solution for Day 1 of Advent of Code 2022
  """

  defp elf_calories(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn x ->
      x
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()
    end)
  end

  def part_1(input) do
    input
    |> elf_calories()
    |> Enum.max()
    |> IO.inspect()
  end

  def part_2(input) do
    input
    |> elf_calories()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
    |> IO.inspect()
  end
end

input = File.read!("input.txt")

CalorieCounting.part_1(input)
CalorieCounting.part_2(input)
