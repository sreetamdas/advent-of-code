defmodule Factory do
  import Bitwise

  defp parse_input(lines) do
    lines
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      tokens = String.split(line, " ")
      [lights | rest] = tokens
      {_joltage, buttons} = List.pop_at(rest, -1)

      goal =
        lights
        |> String.slice(1..-2//1)
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(0, fn
          {"#", i}, acc -> acc ||| (1 <<< i)
          _, acc -> acc
        end)

      button_masks =
        Enum.map(buttons, fn btn ->
          btn
          |> String.slice(1..-2//1)
          |> String.split(",")
          |> Enum.reduce(0, fn s, acc ->
            acc ||| (1 <<< String.to_integer(s))
          end)
        end)

      {goal, button_masks}
    end)
  end

  defp min_presses(goal, buttons) do
    n = length(buttons)

    Enum.reduce(0..((1 <<< n) - 1), n, fn mask, acc ->
      {result, count} =
        buttons
        |> Enum.with_index()
        |> Enum.reduce({0, 0}, fn {btn, i}, {res, cnt} ->
          if (mask >>> i &&& 1) == 1 do
            {Bitwise.bxor(res, btn), cnt + 1}
          else
            {res, cnt}
          end
        end)

      if result == goal and count < acc, do: count, else: acc
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(fn {goal, buttons} -> min_presses(goal, buttons) end)
    |> Enum.sum()
  end

  def part_2(_input) do
    0
  end
end
