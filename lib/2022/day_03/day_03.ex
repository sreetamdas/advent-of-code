defmodule RucksackReorganization do
  @moduledoc """
  Solution for Day 3 of Advent of Code 2022
  """
  alias AdventOfCode.Helpers, as: HelperUtils

  def get_input(),
    do:
      __DIR__
      |> Path.join("input.txt")
      |> HelperUtils.file_input()
      |> String.split("\n", trim: true)

  def get_priority(char),
    do:
      char
      |> String.to_charlist()
      |> hd
      |> then(&(&1 - 96))
      |> then(fn val ->
        cond do
          val < -5 -> val + 58
          true -> val
        end
      end)

  def part_1() do
    get_input()
    |> Enum.map(fn str ->
      [bag_1, bag_2] =
        str
        |> String.split_at(div(String.length(str), 2))
        |> then(fn {first, second} ->
          [first, second]
          |> Enum.map(
            &(String.graphemes(&1)
              |> MapSet.new())
          )
        end)

      MapSet.intersection(bag_1, bag_2)
      |> MapSet.to_list()
      |> Enum.at(0)
      |> get_priority()
    end)
    |> Enum.sum()
  end

  def part_2() do
    get_input()
    |> Enum.chunk_every(3)
    |> Enum.map(fn bag ->
      [first, second, third] =
        bag
        |> Enum.map(
          &(String.graphemes(&1)
            |> MapSet.new())
        )

      MapSet.intersection(first, second)
      |> MapSet.intersection(third)
      |> MapSet.to_list()
      |> Enum.at(0)
      |> get_priority()
    end)
    |> Enum.sum()
  end

  def answers, do: %{part_1: part_1(), part_2: part_2()}
end
