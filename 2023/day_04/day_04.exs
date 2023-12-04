defmodule Scratchcards do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(":")
      |> Enum.at(1)
      |> String.split("|")
      |> Enum.map(fn card_nums ->
        card_nums
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
      end)
    end)
  end

  defp get_matches([winning, mine]) do
    winning
    |> MapSet.new()
    |> MapSet.intersection(MapSet.new(mine))
    |> MapSet.to_list()
    |> length()
  end

  defp get_cards_count(input) do
    map =
      0..(length(input) - 1)
      |> Map.new(&{&1, 1})

    input
    |> Enum.reduce(map, fn {dealt_cards, index}, cards_count_map ->
      case get_matches(dealt_cards) do
        0 ->
          cards_count_map

        matches_count ->
          cards_count_map
          |> Map.take(Enum.to_list((index + 1)..(index + matches_count)))
          |> Map.to_list()
          |> Enum.map(&{elem(&1, 0), elem(&1, 1) + Map.get(cards_count_map, index)})
          |> Enum.into(%{})
          |> then(&Map.merge(cards_count_map, &1))
      end
    end)
    |> Map.values()
    |> Enum.sum()
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(&get_matches/1)
    |> Enum.filter(&(&1 > 0))
    |> Enum.map(&(2 ** (&1 - 1)))
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.with_index()
    |> get_cards_count()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

Scratchcards.part_1(input)
Scratchcards.part_2(input)
