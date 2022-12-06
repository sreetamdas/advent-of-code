defmodule RockPaperScissors do
  @moduledoc """
  Solution for Day 2 of Advent of Code 2022
  """
  @outcomes %{
    A: 1,
    B: 2,
    C: 3,
    X: 1,
    Y: 2,
    Z: 3
  }

  defp get_score([3, 1]), do: 1 + 6
  defp get_score([1, 3]), do: 3
  defp get_score([them, us]) when them > us, do: us
  defp get_score([them, us]) when them < us, do: us + 6
  defp get_score([them, us]) when them == us, do: us + 3

  defp get_outcome([1, 1]), do: 3
  defp get_outcome([them, 1]), do: rem(them - 1, 3)
  defp get_outcome([them, 2]), do: them
  defp get_outcome([2, 3]), do: 3
  defp get_outcome([them, 3]), do: rem(them + 1, 3)

  def elf_moves(input),
    do:
      input
      |> String.split([" ", "\n"], trim: true)
      |> Enum.chunk_every(2)

  def part_1(input) do
    input
    |> elf_moves()
    |> Enum.map(fn [them, us] ->
      [them, us]
      |> Enum.map(&Map.get(@outcomes, String.to_atom(&1)))
      |> get_score()
    end)
    |> Enum.sum()
    |> IO.inspect()
  end

  def part_2(input) do
    input
    |> elf_moves()
    |> Enum.map(fn [them, us] ->
      our_move =
        [them, us]
        |> Enum.map(&Map.get(@outcomes, String.to_atom(&1)))
        |> get_outcome()

      [Map.get(@outcomes, String.to_atom(them)), our_move]
      |> get_score()
    end)
    |> Enum.sum()
    |> IO.inspect()
  end
end

input = File.read!("input.txt")

RockPaperScissors.part_1(input)
RockPaperScissors.part_2(input)
