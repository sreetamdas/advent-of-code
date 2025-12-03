defmodule SecretEntrance do
  defp parse_input(lines) do
    lines
    |> String.split("\n")
    |> Enum.map(fn
      "L" <> count -> -String.to_integer(count)
      "R" <> count -> String.to_integer(count)
    end)
  end

  @start 50

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.reduce({@start, 0}, fn steps, {total, zero_count} ->
      (total + steps)
      |> Integer.mod(100)
      |> case do
        0 -> {0, zero_count + 1}
        x -> {x, zero_count}
      end
    end)
    |> elem(1)
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.reduce({@start, 0}, fn steps, {total, count} ->
      (steps + total)
      |> then(fn updated_total ->
        next =
          updated_total
          |> div(100)
          |> abs()
          |> then(fn x ->
            cond do
              total != 0 and updated_total <= 0 -> x + 1
              true -> x
            end
          end)

        {Integer.mod(updated_total, 100), count + next}
      end)
    end)
    |> elem(1)
  end
end

input = Kino.Input.read(input_raw)
puzzle_input = Kino.Input.read(puzzle_input_raw)
SecretEntrance.part_1(puzzle_input)
# SecretEntrance.part_2(puzzle_input)
