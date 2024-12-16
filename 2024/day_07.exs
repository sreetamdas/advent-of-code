defmodule BridgeRepair do
  def parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn eq ->
      eq
      |> String.split([":", " "], trim: true)
      |> Enum.map(&String.to_integer/1)
      |> then(fn [total | nums] -> {total, nums} end)
    end)
  end

  def concatenate(left, right), do: (to_string(left) <> to_string(right)) |> String.to_integer()

  defp check_is_valid(eq, allow_concatenate \\ false)
  defp check_is_valid({total, [final]}, _), do: total == final

  defp check_is_valid({total, [current | [next | rest]]}, allow_concatenate) do
    cond do
      allow_concatenate ->
        check_is_valid({total, [current + next | rest]}, true) or
          check_is_valid({total, [current * next | rest]}, true) or
          check_is_valid({total, [concatenate(current, next) | rest]}, true)

      true ->
        check_is_valid({total, [current + next | rest]}) or
          check_is_valid({total, [current * next | rest]})
    end
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.filter(&check_is_valid/1)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.filter(&check_is_valid(&1, true))
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

BridgeRepair.part_1(input)
BridgeRepair.part_2(input)
