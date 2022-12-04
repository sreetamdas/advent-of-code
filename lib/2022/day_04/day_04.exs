defmodule CampCleanup do
  @moduledoc """
  Solution for Day 4 of Advent of Code 2022
  """

  def get_input(input),
    do:
      input
      |> String.split([",", "-", "\n"], trim: true)
      |> Enum.map(&String.to_integer(&1))
      |> Enum.chunk_every(2)
      |> Enum.chunk_every(2)

  def part_1(input) do
    input
    |> get_input()
    |> Enum.map(fn [[first_start, first_end], [second_start, second_end]] ->
      cond do
        first_start <= second_start && first_end >= second_end -> true
        first_start >= second_start && first_end <= second_end -> true
        true -> false
      end
    end)
    |> Enum.count(fn x -> x end)
    |> IO.puts()
  end

  def part_2(input) do
    input
    |> get_input()
    |> Enum.map(fn [[first_start, first_end], [second_start, second_end]] ->
      cond do
        first_start <= second_start && first_end >= second_start -> true
        first_start >= second_end && first_end <= second_end -> true
        first_start >= second_start && first_start <= second_end -> true
        first_end >= second_start && first_end <= second_end -> true
        true -> false
      end
    end)
    |> Enum.count(fn x -> x end)
    |> IO.puts()
  end
end

cleaned_input = File.read!("input.txt")

CampCleanup.part_1(cleaned_input)
CampCleanup.part_2(cleaned_input)
