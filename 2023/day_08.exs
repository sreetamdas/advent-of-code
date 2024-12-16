defmodule Wasteland do
  defp parse_input(input) do
    input
    |> String.split(["\n\n", "\n"])
    |> then(fn [instructions | network] ->
      network
      |> Enum.map(fn row ->
        row
        |> String.split([" = ", ", "])
        |> Enum.map(fn
          "(" <> node -> node
          node -> String.trim_trailing(node, ")")
        end)
        |> then(fn [node, left, right] -> {node, {left, right}} end)
      end)
      |> Map.new()
      |> then(&{String.graphemes(instructions), &1})
    end)
  end

  defp walk(_, "ZZZ", _), do: 0
  defp walk(map, node, {[], all_choices}), do: walk(map, node, {all_choices, all_choices})

  defp walk(map, node, {[choice | rest], all_choices}) do
    map
    |> Map.get(node)
    |> then(fn {left, right} ->
      cond do
        choice == "L" -> 1 + walk(map, left, {rest, all_choices})
        true -> 1 + walk(map, right, {rest, all_choices})
      end
    end)
  end

  defp ghost_walk(map, node, {[], all_choices}),
    do: ghost_walk(map, node, {all_choices, all_choices})

  defp ghost_walk(map, node, {[choice | rest], all_choices}) do
    node
    |> String.graphemes()
    |> Enum.reverse()
    |> case do
      ["Z" | _] ->
        0

      _ ->
        map
        |> Map.get(node)
        |> then(fn {left, right} ->
          cond do
            choice == "L" -> 1 + ghost_walk(map, left, {rest, all_choices})
            true -> 1 + ghost_walk(map, right, {rest, all_choices})
          end
        end)
    end
  end

  defp navigate({instructions, map}) do
    map
    |> walk("AAA", {instructions, instructions})
  end

  def part_1(input) do
    input
    |> parse_input()
    |> navigate()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    {instructions, map} =
      input
      |> parse_input()

    map
    |> Map.keys()
    |> Enum.filter(fn key ->
      key
      |> String.graphemes()
      |> Enum.reverse()
      |> then(fn
        ["A" | _] -> true
        _ -> false
      end)
    end)
    |> Enum.map(&ghost_walk(map, &1, {instructions, instructions}))
    |> Enum.reduce(&div(&1 * &2, Integer.gcd(&1, &2)))
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

Wasteland.part_1(input)
Wasteland.part_2(input)
