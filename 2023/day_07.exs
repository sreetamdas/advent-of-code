defmodule CamelCards do
  defp parse_input(input) do
    input
    |> String.split(["\n", " "])
    |> Enum.chunk_every(2)
    |> Enum.map(fn [hand, bid] ->
      {hand, String.to_integer(bid)}
    end)
  end

  @cards_map %{
    "A" => 14,
    "K" => 13,
    "Q" => 12,
    "J" => 11,
    "T" => 10,
    "9" => 9,
    "8" => 8,
    "7" => 7,
    "6" => 6,
    "5" => 5,
    "4" => 4,
    "3" => 3,
    "2" => 2
  }

  defp get_card_power(card, has_joker),
    do: if(has_joker and card == "J", do: 1, else: Map.get(@cards_map, card))

  defp get_frequencies(hand) do
    hand
    |> Enum.frequencies()
  end

  defp get_power({hand, bid}, has_joker \\ false) do
    hand
    |> String.graphemes()
    |> case do
      [x, x, x, x, x] ->
        {7, get_card_power(x, has_joker) |> List.duplicate(5)}

      cards ->
        cards
        |> get_frequencies()
        |> then(fn freq ->
          cond do
            has_joker ->
              {joker_count, without_joker} = Map.pop(freq, "J", 0)

              without_joker
              |> Map.values()
              |> Enum.sort(:desc)
              |> then(fn [top | rest] -> [top + joker_count | rest] end)

            true ->
              Map.values(freq)
              |> Enum.sort(:desc)
          end
        end)
        |> case do
          [5] ->
            7

          [4, 1] ->
            6

          [3, 2] ->
            5

          [3 | _] ->
            4

          [2, 2, 1] ->
            3

          [2 | _] ->
            2

          _ ->
            1
        end
        |> then(fn power -> {power, Enum.map(cards, &get_card_power(&1, has_joker))} end)
    end
    |> then(fn {power, cards} -> {power, cards, bid} end)
  end

  defp compute_powers(cards) do
    cards
    |> Enum.sort()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {{_, _, bid}, index}, sum ->
      sum + bid * (index + 1)
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(&get_power/1)
    |> compute_powers()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(&get_power(&1, true))
    |> compute_powers()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

CamelCards.part_1(input)
CamelCards.part_2(input)
