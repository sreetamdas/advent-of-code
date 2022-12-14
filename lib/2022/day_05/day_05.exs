defmodule SupplyStacks do
  @moduledoc """
  Solution for Day 5 of Advent of Code 2022
  """

  defp get_formatted_input(input) do
    [stacks_raw, moves_raw] =
      input
      |> String.trim_trailing()
      |> String.split("\n\n")

    stacks_cleaned =
      stacks_raw
      |> String.split("\n")
      |> Enum.map(fn row ->
        row
        # 4 spaces when "adjacent" stack slot is empty
        |> String.split(["    ", " "])
        |> Enum.map(&String.replace(&1, ["[", "]"], ""))
      end)
      # remove useless row with stack index
      |> List.delete_at(-1)

    stacks =
      stacks_cleaned
      |> Enum.reduce(%{}, fn row, row_map ->
        parsed_row =
          row
          # process each row
          |> Enum.with_index(fn crate, index ->
            stack_actual =
              row_map
              |> Map.get(index + 1, [])

            case crate do
              "" ->
                %{}

              _ ->
                %{}
                |> Map.put(index + 1, [crate | stack_actual])
            end
          end)
          |> Enum.reduce(%{}, fn map, curr ->
            map
            |> Map.merge(curr)
          end)

        parsed_row
      end)

    moves =
      moves_raw
      |> String.split("\n")
      |> Enum.map(fn instruction ->
        Regex.run(~r"move (\d+) from (\d+) to (\d+)", instruction)
        |> then(fn [_ | str] -> str |> Enum.map(&String.to_integer(&1)) end)
      end)

    [stacks, moves]
  end

  defp move_crates([stacks, moves], order_crate_func) do
    moves
    |> Enum.reduce(stacks, fn [count, from, to], res ->
      {stack_removed, to_move} =
        res
        |> Map.get(from)
        |> Enum.split(-count)
        |> then(fn {x, y} -> {x, order_crate_func.(y)} end)

      updated_stack =
        res
        |> Map.get(to)
        |> Enum.concat(to_move)

      res
      |> Map.put(to, updated_stack)
      |> Map.put(from, stack_removed)
    end)
  end

  defp get_top(map),
    do:
      map
      |> Map.values()
      |> Enum.reduce("", &"#{&2}#{List.last(&1)}")

  defp solve(input, order_crates) do
    input
    |> get_formatted_input()
    |> move_crates(order_crates)
    |> get_top()
    |> IO.puts()
  end

  def part_1(input), do: solve(input, &Enum.reverse/1)
  # part 2 is without any reversing
  def part_2(input), do: solve(input, &Function.identity/1)
end

cleaned_input = File.read!("input.txt")

SupplyStacks.part_1(cleaned_input)
SupplyStacks.part_2(cleaned_input)
