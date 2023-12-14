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
            check_recursively(rest_input, known, 1)

          Enum.at(known, 0) > current_block_len ->
            check_recursively(rest_input, known, current_block_len + 1)

          true ->
            0
        end

      "?" ->
        cond do
          current_block_len == 0 and known == [] ->
            check_recursively(rest_input, [], 0)

          current_block_len == 0 ->
            check_recursively(rest_input, known, 1) + check_recursively(rest_input, known, 0)

          current_block_len == Enum.at(known, 0) ->
            check_recursively(rest_input, Enum.drop(known, 1), 0)

          Enum.at(known, 0) > current_block_len ->
            check_recursively(rest_input, known, current_block_len + 1)

          true ->
            0
        end

      "." ->
        cond do
          current_block_len == 0 ->
            check_recursively(rest_input, known, 0)

          current_block_len == Enum.at(known, 0) ->
            check_recursively(rest_input, Enum.drop(known, 1), 0)

          true ->
            0
        end
    end
  end

  defp check_recursively(_, _, _), do: 0

  defp solve(input, known, current_block_len) do
    # cache

    check_recursively(input, known, current_block_len)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(fn {input, known} -> solve(input, known, 0) end)
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end
end

input = Kino.Input.read(input_raw)

HotSprings.part_1(input)
# HotSprings.check({"#.#.###", [1, 1, 3]})
# HotSprings.part_2(input)
