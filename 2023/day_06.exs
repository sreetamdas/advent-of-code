defmodule WaitForIt do
  defp get_wins_count({total_time, max_distance}) do
    0..total_time
    |> Enum.map(fn time ->
      speed = total_time - time

      time * speed
    end)
    |> Enum.filter(&(&1 > max_distance))
    |> Enum.count()
  end

  def part_1(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn row ->
      Regex.scan(~r/\d+/, row) |> List.flatten() |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
    |> Enum.map(&get_wins_count/1)
    |> Enum.product()
    |> IO.inspect(label: "part_1", charlists: :as_lists)
  end

  def part_2(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn row ->
      Regex.scan(~r/\d+/, row) |> Enum.join() |> String.to_integer()
    end)
    |> List.to_tuple()
    |> get_wins_count()
    |> IO.inspect(label: "part_2", charlists: :as_lists)
  end
end

input = File.read!("input.txt")

WaitForIt.part_1(input)
WaitForIt.part_2(input)
