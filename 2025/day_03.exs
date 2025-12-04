defmodule Lobby do
  defp parse_input(lines) do
    lines
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.trim()
      |> String.to_integer()
    end)
  end

  defp get_largest_num(num, digit_count) do
    num
    |> Integer.digits()
    |> then(fn digits ->
      digits
      |> Enum.with_index()
      |> then(fn digits_with_index ->
        digits_with_index
        |> Enum.reduce_while({{0, -digit_count}, []}, fn _, {{start, finish}, list} ->
          digits_with_index
          |> Enum.slice(start..finish//1)
          |> then(fn slice ->
            slice
            |> Enum.max_by(&elem(&1, 0), fn -> {Enum.at(list, 0), start} end)
            |> then(fn
              {curr_max_num, curr_max_index} ->
                cond do
                  finish == -1 ->
                    max_num =
                      [curr_max_num | list]
                      |> Enum.reverse()
                      |> Integer.undigits()

                    {:halt, max_num}

                  true ->
                    {:cont, {{curr_max_index + 1, finish + 1}, [curr_max_num | list]}}
                end
            end)
          end)
        end)
      end)
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(&get_largest_num(&1, 2))
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(&get_largest_num(&1, 12))
    |> Enum.sum()
    |> IO.inspect(label: "part_2")
  end
end

input = AdventOfCode.Helpers.file_input(__ENV__.file)

Lobby.part_1(input)
Lobby.part_2(input)
