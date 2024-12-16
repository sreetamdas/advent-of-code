defmodule MirageMaintenance do
  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Enum.map(fn history ->
      history
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp extrapolate(history, edges \\ [], at_beginning \\ false) do
    el_index = if at_beginning, do: 0, else: -1

    history
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [first, second] -> second - first end)
    |> then(fn diff ->
      Enum.all?(diff, &(&1 == 0))
      |> case do
        true -> [Enum.at(history, el_index) | edges]
        false -> extrapolate(diff, [Enum.at(history, el_index) | edges], at_beginning)
      end
    end)
  end

  def part_1(input) do
    input
    |> parse_input()
    |> Enum.map(fn history ->
      history
      |> extrapolate()
      |> Enum.reduce(0, &(&1 + &2))
    end)
    |> Enum.sum()
    |> IO.inspect(label: "part_1")
  end

  def part_2(input) do
    input
    |> parse_input()
    |> Enum.map(fn history ->
      history
      |> extrapolate([], true)
      |> Enum.reduce(0, &(&1 - &2))
    end)
    |> Enum.sum()
    |> IO.inspect(label: "part_2")
  end
end

input = File.read!("input.txt")

MirageMaintenance.part_1(input)
MirageMaintenance.part_2(input)
