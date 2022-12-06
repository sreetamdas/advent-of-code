defmodule TuningTrouble do
  @moduledoc """
  Solution for Day 6 of Advent of Code 2022
  """

  @scan_size_part_1 4
  @scan_size_part_2 14

  defp get_cleaned_input(input),
    do:
      input
      |> String.trim_trailing()
      |> String.graphemes()

  defp scan_signal(signal, scan_size) do
    signal
    |> Enum.chunk_every(scan_size, 1, :discard)
    |> Enum.reduce_while(scan_size, fn chunk, res ->
      chunk
      |> Enum.uniq()
      |> then(
        &case Enum.count(&1) do
          ^scan_size -> {:halt, res}
          _ -> {:cont, res + 1}
        end
      )
    end)
  end

  def part_1(input),
    do:
      input
      |> get_cleaned_input()
      |> scan_signal(@scan_size_part_1)
      |> IO.inspect(label: "part_1")

  def part_2(input),
    do:
      input
      |> get_cleaned_input()
      |> scan_signal(@scan_size_part_2)
      |> IO.inspect(label: "part_2")
end

input = File.read!("input.txt")

TuningTrouble.part_1(input)
TuningTrouble.part_2(input)
