defmodule HotSprings do
  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn line ->
      [a, b] = String.split(line, " ")

      input = String.graphemes(a)

      known =
        b
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)

      {input, known}
    end)
  end

  defp check_recursively([], [x1], x2) when x1 == x2, do: 1
  defp check_recursively([], [], 0), do: 1
  defp check_recursively([], _, _), do: 0

  defp check_recursively([maybe_spring | rest_input], known, current_block_len) do
    case maybe_spring do
      "#" ->
        cond do
          # segments remaining to be matched
          current_block_len == 0 and length(known) > 0 ->
            solve(rest_input, known, 1)

          Enum.at(known, 0) > current_block_len ->
            solve(rest_input, known, current_block_len + 1)

          true ->
            0
        end

      "?" ->
        cond do
          current_block_len == 0 and known == [] ->
            solve(rest_input, [], 0)

          current_block_len == 0 ->
            solve(rest_input, known, 1) + solve(rest_input, known, 0)

          current_block_len == Enum.at(known, 0) ->
            solve(rest_input, Enum.drop(known, 1), 0)

          Enum.at(known, 0) > current_block_len ->
            solve(rest_input, known, current_block_len + 1)

          true ->
            0
        end

      "." ->
        cond do
          current_block_len == 0 ->
            solve(rest_input, known, 0)

          current_block_len == Enum.at(known, 0) ->
            solve(rest_input, Enum.drop(known, 1), 0)

          true ->
            0
        end
    end
  end

  defp solve(input, known, current_block_len) do
    case :ets.lookup(:aoc_2023_day_12, {input, known, current_block_len}) do
      [] ->
        check_recursively(input, known, current_block_len)
        |> then(fn res ->
          :ets.insert(:aoc_2023_day_12, {{input, known, current_block_len}, res})

          res
        end)

      [{_, res}] ->
        res
    end
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(fn {input, known} -> solve(input, known, 0) end)
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(fn {input, known} ->
      {List.flatten(List.duplicate(input, 5) |> Enum.intersperse("?")),
       List.flatten(List.duplicate(known, 5))}
    end)
    |> Enum.map(fn {input, known} -> solve(input, known, 0) end)
    |> Enum.sum()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

:ets.new(:aoc_2023_day_12, [:named_table])
HotSprings.part_1(input)
HotSprings.part_2(input)
:ets.delete(:aoc_2023_day_12)
