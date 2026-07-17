defmodule Factory do
  import Bitwise

  defp parse_input(lines) do
    lines
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      tokens = String.split(line, " ")
      [lights | rest] = tokens
      {joltage_str, button_strs} = List.pop_at(rest, -1)

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
        Enum.map(button_strs, fn btn ->
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

  def part_2(input) do
    tmp = Path.join(System.tmp_dir!(), "aoc2025_day10_input.txt")
    File.write!(tmp, input)
    script = Path.join(__DIR__, "part2_z3.py")
    {result, 0} = System.cmd("python3", [script, tmp])
    {count, _} = Integer.parse(String.trim(result))
    count
  end
end
