defmodule AdventOfCode.Year2022.Day01 do
  @moduledoc """
  Solution for Day 1 of Advent of Code 2022: Calorie Counting
  """
  alias AdventOfCode.Helpers, as: HelperUtils

  defp elf_calories do
    # Current directory
    __DIR__
    |> Path.join("input.txt")
    |> HelperUtils.file_input()
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn x ->
      x
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()
    end)
  end

  def part_1 do
    elf_calories()
    |> Enum.max()
  end

  def part_2 do
    elf_calories()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end

  def answers do
    %{part_1: part_1(), part_2: part_2()}
  end
end
